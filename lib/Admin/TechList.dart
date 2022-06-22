import 'dart:convert';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/CreateClient.dart';
import 'package:frontend/Admin/CreateTech.dart';
import 'package:frontend/Technicien/CpeDetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'AdminNavigation_drawer_widget.dart';
import 'TechDetail.dart';

class TechList extends StatefulWidget {
  final String? email;

  const TechList({Key? key, this.email}) : super(key: key);
  @override
  _TechListState createState() => _TechListState();
}

final List<String> Working_city = [
  '____',
  'Ariana',
  'Tunis',
  'Ben Arous',
  'Manouba',
];
//String email1 = '', name = '';

//final _formKey = GlobalKey<FormState>();

const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 20);

//List<Tech> techs = [];
//int id = 0;

class _TechListState extends State<TechList> {
  String? working_city_;
  String? email;

  @override
  void initState() {
    List<Tech> techs = [];
    String working_city_;
    String? email;
  }

  @override
  Future<List<Tech>> _getTech() async {
    List<Tech> techs = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    // email1 = Jwt.parseJwt(token.toString())['email'];
    // name = Jwt.parseJwt(token.toString())['username'];
    //setState(() {});

    //print(token);
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var techListEndPoint = "/api/tech";
    final queryParameters = {
      'working_city': working_city_ == '____' ? '' : working_city_,
      'email': email
    };

    var response = await http.get(
      Uri.https(host, techListEndPoint,
          queryParameters), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) {
      //refresh token and call getUser again
      var refreshToken = prefs.getString('refreshToken');
      //var host = "127.0.0.1:8000"; //10.0.2.2:8000
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
      var TechList = jsonDecode(response.body);

      print(TechList);

      for (var tech in TechList) {
        Tech tech_ = Tech(tech['username'], tech["email"], tech["tel"],
            tech["city"], tech["working_city"], tech["cpe_count"], tech["id"]);
        techs.add(tech_);
      }
    }
    print(techs.length);
    return techs;
  }

  _deleteTech(int id) async {
    List<int> tech_ids = [];
    tech_ids.add(id);
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var techDeleteEndPoint = "api/tech/delete_techs/";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    var response = await http.delete(
      Uri.https(host,
          techDeleteEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'tech_ids': tech_ids}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      setState(() {});
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'), content: Text('Tech Has been deleted'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop();
      });

      /* Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TechList(),
      ))*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AdminNavigationDrawerWidget(),
        appBar: AppBar(
          title: Text('All Techniciens List'),
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateTech(),
                  ));
                },
                child: Icon(Icons.add))),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          shrinkWrap: true,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: TextFormField(
                  onChanged: (value) {
                    if (RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!)) {
                      this.setState(() {
                        email = value;
                      });
                      print('First text field: $value');
                    } else {
                      if (email != "") {
                        this.setState(() {
                          email = "";
                        });
                      }
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "enter tech's e-mail",
                    labelText: "tech's e-mail",
                  ),
                ),
              ),
              CustomDropdownButton2(
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                buttonDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black45,
                  ),
                ),
                dropdownWidth: MediaQuery.of(context).size.width * 0.3,
                buttonPadding: const EdgeInsets.all(10.0),
                scrollbarRadius: const Radius.circular(2),
                hint: 'Working City',
                dropdownItems: Working_city,
                value: working_city_,
                buttonHeight: 59,
                buttonWidth: MediaQuery.of(context).size.width * 0.3,
                onChanged: (value) {
                  print("below !!!!!!!!!!!!!!");

                  setState(() {
                    working_city_ = value;
                  });
                  print(working_city_);
                },
              ),
            ]),
            const SizedBox(height: 20),
            FutureBuilder(
              future: _getTech(),
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
                        leading: Image.asset('images/tech.jpg'),
                        title: Text(snapshot.data[index].email,
                            style: const TextStyle(fontSize: 15)),
                        //subtitle: Text(snapshot.data[index].temperature),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Text("name: " +
                                    snapshot.data[index].username +
                                    " "),
                                Text("    city : " +
                                    snapshot.data[index].working_city +
                                    " "),
                              ],
                            ),
                            Text("Cpe: " +
                                snapshot.data[index].cpe_count.toString())
                          ],
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => new AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.red, width: 2)),
                                  title: Row(children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 5, height: 5),
                                    Text(
                                      "Are you sure to delete this Tech?",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ]),
                                  content: Text(
                                    "It will delete this Tech permanently.",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.orange)),
                                      child: Text("Delete"),
                                      onPressed: () =>
                                          _deleteTech(snapshot.data[index].id),
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
                                              .pop('dialog'); // Return false
                                        }),
                                  ],
                                ),
                              );
                            }),

                        onTap: () {
                          print(snapshot.data[index].id);

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                TechDetail(id: snapshot.data[index].id),
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

class Tech {
  String username;
  String email;
  String tel;
  String city;
  String working_city;
  int cpe_count;
  int id;

  Tech(
    this.username,
    this.email,
    this.tel,
    this.city,
    this.working_city,
    this.cpe_count,
    this.id,
  );
}
