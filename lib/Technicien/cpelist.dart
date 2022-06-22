import 'dart:convert';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/AdminNavigation_drawer_widget.dart';
import 'package:frontend/Technicien/CpeDetailPage.dart';
import 'package:frontend/Technicien/StatusWidget.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'navigation_drawer_widget.dart';

class CpeList extends StatefulWidget {
  const CpeList({
    Key? key,
  }) : super(key: key);

  @override
  _CpeListState createState() => _CpeListState();
}

class _CpeListState extends State<CpeList> {
  final List<String> Status = [
    '____',
    'On',
    'Off',
  ];
  final List<String> OrderByItems = [
    '__________',
    'temperature',
    'cpu_usage',
    'ram_usage',
  ];
  //String? email, name;

  final _formKey = GlobalKey<FormState>();
  int status_ = -1;

  List<Cpe> cpes = [];
  int id = 0;
  late bool IsAdmin;
  String? order_by;
  String? status;
  @override
  void initState() {
    // List<Cpe> cpes = [];
    String? orderBy;
    String? status;
  }

  @override
  Future<List<Cpe>> _getCpe() async {
    List<Cpe> cpes = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();
    var isAdmin = Jwt.parseJwt(token!)['is_admin'];
    // email = Jwt.parseJwt(token.toString())['email'];
    //name = Jwt.parseJwt(token.toString())['username'];
    //print(token);
    //var host = "efbf-102-25-171-90.eu.ngrok.io";
    var cpeListEndPoint = "/api/cpe_list";
    final queryParameters = {
      'order_by': order_by == '__________' ? '' : order_by,
      'status': status == '____' || status == null
          ? ''
          : status == 'On'
              ? 'true'
              : 'false',
    };

    var response = await http.get(
      Uri.https(host, cpeListEndPoint,
          queryParameters), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) {
      //refresh token and call getUser again
      var refreshToken = prefs.getString('refreshToken');
      var host = "http://10.0.2.2:8000";
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
        Cpe cpe_ = Cpe(cpe["client"]['username'], cpe["temperature"],
            cpe["cpu_usage"], cpe["ram_usage"], cpe["status"], cpe["id"]);
        cpes.add(cpe_);
      }
    }
    print(cpes.length);

    return cpes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          title: Text('MY CPE LIST'),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          shrinkWrap: true,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              CustomDropdownButton2(
                buttonPadding: const EdgeInsets.all(10.0),
                hint: 'Order By',
                dropdownItems: OrderByItems,
                value: order_by,
                buttonWidth: MediaQuery.of(context).size.width * 0.6,
                onChanged: (value) {
                  setState(() {
                    order_by = value;
                  });
                },
              ),
              CustomDropdownButton2(
                dropdownWidth: 120,
                buttonPadding: const EdgeInsets.all(10.0),
                scrollbarRadius: const Radius.circular(2),
                hint: 'Status',
                dropdownItems: Status,
                value: status,
                buttonWidth: MediaQuery.of(context).size.width * 0.3,
                onChanged: (value) {
                  print("below !!!!!!!!!!!!!!");
                  print(order_by);
                  setState(() {
                    status = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 20),
            FutureBuilder(
              future: _getCpe(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print(snapshot.data);
                if (snapshot.data == null) {
                  return Container(
                      child: const Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        isThreeLine: true,
                        leading: Image.asset('images/cpe.jpg'),
                        title: Text(
                            "client : " +
                                (snapshot.data[index].client_name.toString() ==
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
                                Text("Tmp: " +
                                    snapshot.data[index].temperature
                                        .toString() +
                                    " "),
                                Text("Cpu: " +
                                    snapshot.data[index].cpu_usage.toString() +
                                    " "),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Ram: " +
                                    snapshot.data[index].ram_usage.toString() +
                                    " "),
                                snapshot.data[index].status
                                    ? const Text("Status: On")
                                    : const Text("Status: Off"),
                              ],
                            ),
                          ],
                        ),
                        trailing: StatusWidget(
                            status: snapshot.data[index].status ? 1 : 0),
                        //<Widget>[StatusWidget(status: status_)],
                        onTap: () {
                          print(snapshot.data[index].id);

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CpeDetail(
                              id: snapshot.data[index].id,
                            ),
                          ));
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ));
  }
}

class Cpe {
  final String? client_name;
  final double temperature;
  final double cpu_usage;
  final double ram_usage;
  final bool status;
  final int id;

  Cpe(this.client_name, this.temperature, this.cpu_usage, this.ram_usage,
      this.status, this.id);
}
//no cpe list with a cpe without a client 