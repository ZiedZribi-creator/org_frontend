import 'dart:convert';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/CreateClient.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'AdminNavigation_drawer_widget.dart';
import 'Client.dart';
import 'ClientDetail.dart';

class ClientList extends StatefulWidget {
  const ClientList({Key? key}) : super(key: key);

  @override
  _ClientListState createState() => _ClientListState();
}

//List<Tech> techs = [];
//int id = 0;

class _ClientListState extends State<ClientList> {
  final List<String> City = [
    '____',
    'Ariana',
    'Tunis',
    'Ben Arous',
    'Manouba',
  ];
  //String email1 = '', name = '';

  //final _formKey = GlobalKey<FormState>();

//List<Tech> techs = [];
//int id = 0;
  String? city;
  String? email;

  @override
  void initState() {
    List<Client> clients = [];
    String city;
    String? email;
  }

  @override
  Future<List<Client>> _getClient() async {
    List<Client> clients = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    //email1 = Jwt.parseJwt(token.toString())['email'];
    //name = Jwt.parseJwt(token.toString())['username'];
    //setState(() {});
    //print(token);
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var techListEndPoint = "/api/client_list";
    final queryParameters = {
      'city': city == '____' ? '' : city,
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
      var ClientList = jsonDecode(response.body);

      print(ClientList);

      for (var client in ClientList) {
        Client client_ = Client(
            client['username'],
            client["email"],
            client["tel"],
            client["city"],
            client["address"],
            client["id"],
            client["cpe_count"]);

        clients.add(client_);
      }
    }
    print(clients.length);

    return clients;
  }

  _deleteClient(int id) async {
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var ClientDeleteEndPoint = "api/client/" + id.toString() + "/delete";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    var response = await http.delete(
      Uri.https(host,
          ClientDeleteEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'),
                content: Text('Client Has been deleted'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
      setState(() {});
      /*Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ClientList(),
      ));*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AdminNavigationDrawerWidget(),
        appBar: AppBar(
          title: Text('All Clients List'),
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
                    builder: (context) => CreateClient(),
                  ));
                },
                child: Icon(Icons.add))),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          shrinkWrap: true,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Container(
                height: 59,
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
                    hintText: "enter client's e-mail",
                    labelText: "client's e-mail",
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
                //dropdownHeight: 59,
                buttonPadding: const EdgeInsets.all(10.0),
                scrollbarRadius: const Radius.circular(2),
                hint: 'City',
                dropdownItems: City,
                value: city,
                buttonHeight: 59,
                buttonWidth: MediaQuery.of(context).size.width * 0.3,
                onChanged: (value) {
                  print("below !!!!!!!!!!!!!!");

                  setState(() {
                    city = value;
                  });
                  print(city);
                },
              ),
            ]),
            const SizedBox(height: 20),
            FutureBuilder(
              future: _getClient(),
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
                          leading: Image.asset('images/client.jpg'),
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
                                      snapshot.data[index].city +
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
                                        "Are you sure to delete this Client ?",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ]),
                                    content: Text(
                                      "It will delete Client permanently.",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.orange)),
                                        child: Text("Delete"),
                                        onPressed: () => _deleteClient(
                                            snapshot.data[index].id),
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
                                  ClientDetail(id: snapshot.data[index].id),
                            ));
                          });
                    },
                  );
                }
              },
            ),
          ],
        ));
  }
}
