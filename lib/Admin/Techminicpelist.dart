import 'dart:convert';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/AdminNavigation_drawer_widget.dart';
import 'package:frontend/Admin/TechDetail.dart';
import 'package:frontend/Technicien/CpeDetailPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class MiniCpeList extends StatefulWidget {
  final int tech_id;

  const MiniCpeList({Key? key, required this.tech_id}) : super(key: key);

  @override
  _MiniCpeListState createState() => _MiniCpeListState();
}

class _MiniCpeListState extends State<MiniCpeList> {
  final _formKey = GlobalKey<FormState>();
  List<CpeBox> cpe_checkboxes = [];
  int id = 0;
  bool _value = false;
  late Future<List<Cpe>> cpes_;
  @override
  void initState() {
    cpes_ = _getCpe();
  }

  @override
  Future<List<Cpe>> _getCpe() async {
    print("update :::::::::::::::::::::::::::::::::::::");
    List<Cpe> cpes = [];
    List<CpeBox> cpe_checkboxes_ = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    //print(token);
    //var host = "efbf-102-25-171-90.eu.ngrok.io";//10.0.2.2:8000
    var cpeListEndPoint = "/api/cpe_list";
    final queryParameters = {
      'tech_id': widget.tech_id.toString(),
    };
    print(queryParameters);
    var response = await http.get(
      Uri.https(host, cpeListEndPoint, queryParameters),
      // queryParameters), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 401) {
      //refresh token and call getUser again
      var refreshToken = prefs.getString('refreshToken');
      //var host = "http://10.0.2.2:8000";
      var refreshTokenPoint = "api/token/refresh/";
      var response = await http.get(
        Uri.parse(host + refreshTokenPoint),
        // Send authorization headers to the backend.
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $refreshToken',
        },
      );
    } else if (response.statusCode == 200) {
      var cpeList = jsonDecode(response.body);
      print(cpeList);

      for (var cpe in cpeList) {
        Cpe cpe_ = Cpe(
            cpe["client"]['username'],
            cpe["temperature"],
            cpe["cpu_usage"],
            cpe["ram_usage"],
            cpe["status"],
            cpe["id"],
            cpe["tech_email"]);
        cpes.add(cpe_);
        cpe_checkboxes_.add(CpeBox(cpe['id'], false));
      }
      this.setState(() {
        cpe_checkboxes = cpe_checkboxes_;
      });
    }
    print(cpes.length);

    return cpes;
  }

  Future addCpes() async {
    List<int> cpe_ids = [];
    for (CpeBox cpe_checkbox in cpe_checkboxes) {
      if (cpe_checkbox.is_checked) {
        cpe_ids.add(cpe_checkbox.cpe_id);
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    //print(token);
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var techAddCpeEndPoint = "/api/tech/${widget.tech_id}/add_cpe/";

    var response = await http.put(
      Uri.https(host, techAddCpeEndPoint),
      // queryParameters), //host + cpe_list_end_point,queryParameters=queryParameters),
      body: jsonEncode({'cpe_ids': cpe_ids}),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TechDetail(
          id: widget.tech_id,
        ),
      ));
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'),
                content: Text('Cpe Has been added to this tech'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }

    print(cpe_ids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //drawer: NavigationDrawerWidget(),
        /*appBar: AppBar(
          title: Text('Cpes of the city'),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),*/
        body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(height: 20),
        FutureBuilder(
          future: cpes_,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(snapshot.data);
            if (snapshot.data == null) {
              return Container(child: const Center(child: Text("Loading...")));
            } else if (snapshot.data.length == 0) {
              return Text(
                "   No Cpes at the moment ",
                style: GoogleFonts.pacifico(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.orange),
              );
            } else {
              return Column(children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        CheckboxListTile(
                            //CheckboxListTile
                            isThreeLine: true,
                            secondary: Image.asset('images/cpe.jpg'),
                            //leading: Image.asset('images/cpe.jpg'),
                            title: Text(
                                "client : " +
                                    (snapshot.data[index].client_name
                                                .toString() ==
                                            'null'
                                        ? "<NONE>"
                                        : snapshot.data[index].client_name
                                            .toString()),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                )),
                            //subtitle: Text(snapshot.data[index].temperature),
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    Text("Tech: " +
                                        snapshot.data[index].tech_email +
                                        " "),
                                  ],
                                ),
                                Row(children: [
                                  Text("Status: "),
                                  snapshot.data[index].status
                                      ? const Text("On")
                                      : const Text("Off"),
                                ])
                              ],
                            ),
                            /* trailing: Checkbox(
                            value: _value,
                            onChanged: (bool? value) {
                              setState(() {
                                _value = value;
                              });
                            },
                          )*/
                            autofocus: false,
                            activeColor: Colors.orange,
                            checkColor: Colors.white,
                            selected: cpe_checkboxes[index].is_checked,
                            value: cpe_checkboxes[index].is_checked,
                            onChanged: (value) {
                              setState(() {
                                cpe_checkboxes[index].is_checked = value!;
                              });
                            }),
                      ],
                    );
                  },
                ),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    height: 40,
                    width: 80,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.pink,
                            backgroundColor: Colors.orange),

                        /* shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),*/
                        onPressed: addCpes,
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )))
              ]);
            }
          },
        ),
      ],
    ));
  }
}

class Cpe {
  final String? client_name;
  final String? tech_email;
  final double temperature;
  final double cpu_usage;
  final double ram_usage;
  final bool status;
  final int id;

  Cpe(this.client_name, this.temperature, this.cpu_usage, this.ram_usage,
      this.status, this.id, this.tech_email);
}

class CpeBox {
  int cpe_id;
  bool is_checked;

  CpeBox(this.cpe_id, this.is_checked);
}
//no cpe list with a cpe without a client 