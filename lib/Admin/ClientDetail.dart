import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/Clientmincpelist.dart';
import 'package:frontend/Admin/CreateTech.dart';
import 'package:frontend/Admin/Techminicpelist.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Technicien/CustomDropdownButton.dart';
import 'AdminNavigation_drawer_widget.dart';

class ClientDetail extends StatefulWidget {
  final int id;

  const ClientDetail({
    required this.id,
  });
  @override
  State<ClientDetail> createState() => _ClientDetailState();
}

final _StatusKey = GlobalKey<FormState>();

class _ClientDetailState extends State<ClientDetail> {
  late Clienty client;
  //String email = '', name = '';
  late Future<Clienty> client_;
  final _formKey = GlobalKey<FormState>();
  final List<String> City = [
    'Ariana',
    'Tunis',
    'Ben Arous',
    'Manouba',
  ];
  String? city;

  //Cpe cpe_ = new Cpe("",);
  @override
  void initState() {
    client_ = _getClient();
  }

  Future<Clienty> _getClient() async {
    //late Clienty client;
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var clientDetailEndPoint = "/api/client/" + widget.id.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    //email = Jwt.parseJwt(token.toString())['email'];
    //name = Jwt.parseJwt(token.toString())['username'];
    //setState(() {});
    var response = await http.get(
      Uri.https(host,
          clientDetailEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
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
      var clientDetail = jsonDecode(response.body);
      print(clientDetail);

      List<Cpe> cpe_list = [];
      print(clientDetail['cpe_list']);
      for (var cpe in clientDetail['cpe_list']) {
        Cpe cpe_ = Cpe(cpe["client"]['username'], cpe["temperature"],
            cpe["cpu_usage"], cpe["ram_usage"], cpe["status"], cpe["id"]);
        cpe_list.add(cpe_);
      }

      client = Clienty(
          clientDetail['id'],
          clientDetail['username'],
          clientDetail['email'],
          clientDetail['tel'],
          clientDetail['address'],
          clientDetail['city'],
          cpe_list);
      print(client.username);
    }
    this.setState(() {
      city = client.city;
    });
    return client;
  }

  _removeCpe(int id) async {
    List<int> cpe_ids = [];
    cpe_ids.add(id);
    // var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var techDetailEndPoint = "api/client/remove_cpe";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    var host = prefs.getString('host').toString();

    var response = await http.put(
      Uri.https(host,
          techDetailEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cpe_ids': cpe_ids}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'),
                content: Text('Cpe Has been removed from this Client'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
      setState(() {
        client_ = _getClient();
      });
    }
  }

  Future updateClient() async {
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var updateClientEndPoint = "api/client/${widget.id}/update";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    var host = prefs.getString('host').toString();

    // 'email','username','tel','city','address','client_id'
    print({
      'username': client.username,
      'email': client.email,
      'tel': client.tel,
      'addreess': client.address,
      'city': city,
    });
    var response = await http.put(
      Uri.https(host,
          updateClientEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        'username': client.username,
        'email': client.email,
        'tel': client.tel,
        'address': client.address,
        'city': city,
        'client_id': widget.id
      }),
    );
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'),
                content: Text('Client Has been Updated '));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    } else if (response.statusCode == 400) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Error'), content: Text('email already used '));
          });
      Future.delayed(Duration(seconds: 4), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      drawer: AdminNavigationDrawerWidget(),
      appBar: AppBar(
        title: Text(" Client details "),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.orange,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => new AlertDialog(
                          insetPadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.zero,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          content: Builder(
                            builder: (context) {
                              var height = MediaQuery.of(context).size.height;
                              var width = MediaQuery.of(context).size.width;
                              return Container(
                                  height: height - 300,
                                  width: width - 20,
                                  child:
                                      ClientMiniCpeList(client_id: widget.id));
                            },
                          ),
                        )).then((value) {
                  print("closed :::::::::::::::::::::::::::::::::::::::::::");
                });
              },
              child: Icon(Icons.add))),
      body: ListView(children: [
        FutureBuilder(
            future: client_,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print(snapshot.data);
              if (snapshot.data == null) {
                return Container(
                    child: const Center(child: Text("Loading...")));
              } else {
                return Column(
                  children: [
                    Container(
                      child: Form(
                        key: _formKey,
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                              side:
                                  BorderSide(color: Colors.orange, width: 1.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          shadowColor: Colors.orange,
                          child: Column(children: [
                            Container(
                              margin: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                controller: TextEditingController(
                                    text: client.username),

                                onChanged: (value) {
                                  client.username = value;
                                },
                                //onChanged: ,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                  controller:
                                      TextEditingController(text: client.email),
                                  onChanged: (value) {
                                    client.email = value;
                                  }),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                  controller:
                                      TextEditingController(text: client.tel),
                                  onChanged: (value) {
                                    client.tel = value;
                                  }),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: client.address),
                                  onChanged: (value) {
                                    client.address = value;
                                  }),
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                        // width: 16.0,
                                        color: Color.fromARGB(99, 0, 0, 0)),
                                  )),
                                  child: Row(
                                    children: [
                                      Text("  City:  "),
                                      CustomDropdownButton2(
                                        dropdownDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        buttonDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          /*border: Border.all(
                                            color: Color.fromARGB(97, 0, 0, 0),
                                          ),*/
                                        ),

                                        dropdownWidth:
                                            200, //MediaQuery.of(context).size.width * 0.3,
                                        buttonPadding:
                                            const EdgeInsets.all(10.0),
                                        scrollbarRadius:
                                            const Radius.circular(2),
                                        hint: 'City',
                                        dropdownItems: City,
                                        value: city,
                                        buttonHeight: 50,
                                        buttonWidth:
                                            320, //MediaQuery.of(context).size.width * 0.3,
                                        onChanged: (value) {
                                          print("below !!!!!!!!!!!!!!");

                                          this.setState(() {
                                            city = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 45,
                              decoration: BoxDecoration(
                                  //border: Border.all(color: Colors.orange),
                                  ),
                              child: FloatingActionButton(
                                child: Icon(CommunityMaterialIcons.pencil_plus),
                                backgroundColor: Colors.orange,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    updateClient();
                                  } else {
                                    print("not ok");
                                  }
                                },
                              ),
                            )
                          ]),
                        ),
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          //border: Border.all(color: Colors.orange),
                          ),
                      child: Center(
                        child: Text(
                          "cpe list :",
                          style: GoogleFonts.pacifico(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.orange),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                      ),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.cpe_list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            isThreeLine: true,
                            leading: Image.asset('images/cpe.jpg'),
                            title: Text(
                                "client : " +
                                    (snapshot.data.cpe_list[index].client_name
                                                .toString() ==
                                            'null'
                                        ? "<NONE>"
                                        : snapshot
                                            .data.cpe_list[index].client_name
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
                                        snapshot
                                            .data.cpe_list[index].temperature
                                            .toString() +
                                        " "),
                                    Text("Cpu: " +
                                        snapshot.data.cpe_list[index].cpu_usage
                                            .toString() +
                                        " "),
                                  ],
                                ),
                                Row(children: [
                                  Text("Ram: " +
                                      snapshot.data.cpe_list[index].ram_usage
                                          .toString() +
                                      " "),
                                  Text("Status: "),
                                  snapshot.data.cpe_list[index].status
                                      ? const Text("On")
                                      : const Text("Off"),
                                ])
                              ],
                            ),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => new AlertDialog(
                                      title: Text("Confirm"),
                                      content: Text(
                                          "Are you sure to remove this Cpe from this Client?"),
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.orange, width: 3),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      actions: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.orange)),
                                          child: Text("Remove"),
                                          onPressed: () => _removeCpe(
                                              snapshot.data.cpe_list[index].id),
                                        ),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.orange)),
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop(
                                                      'dialog'); // Return false
                                            }),
                                      ],
                                    ),
                                  );
                                }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 45),
                  ],
                );
              }
            })
      ]),
    );
  }
}

class Clienty {
  int? id;
  String? username;
  String? email;
  String? tel;
  String? address;
  String? city;
  List<Cpe> cpe_list;

  Clienty(this.id, this.username, this.email, this.tel, this.address, this.city,
      this.cpe_list);
}

class Cpe {
  final String client_name;
  final double temperature;
  final double cpu_usage;
  final double ram_usage;
  final bool status;
  final int id;

  Cpe(this.client_name, this.temperature, this.cpu_usage, this.ram_usage,
      this.status, this.id);
}
