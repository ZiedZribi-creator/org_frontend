import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/Admin/AdminNavigation_drawer_widget.dart';
import 'package:frontend/Admin/ClientList.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Technicien/CustomDropdownButton.dart';
import 'TechList.dart';

class CreateClient extends StatefulWidget {
  const CreateClient({Key? key}) : super(key: key);

  @override
  _CreateClientState createState() => _CreateClientState();
}

class _CreateClientState extends State<CreateClient> {
  final _formKey1 = GlobalKey<FormState>();
  final navigatorKey = GlobalKey<NavigatorState>();
  final List<String> City = [
    'Ariana',
    'Tunis',
    'Ben Arous',
    'Manouba',
  ];
  String? city;
  //String email = '', name = '';

  @override
  void initState() {
    String? city;
  }

  Future save() async {
    //192.168.1.12
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var host = prefs.getString('host').toString();
    var hosst = "https://" + host; //10.0.2.2:8000
    var create_client_end_point = "/api/create_client";
    var token = prefs.getString('token');

    //email = Jwt.parseJwt(token.toString())['email'];
    // name = Jwt.parseJwt(token.toString())['username'];
    setState(() {});
    var res = await http.post(Uri.parse(hosst + create_client_end_point),
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
          //'clien_id': 0
        }));

    if (res.statusCode == 200) {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => ClientList()));
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'),
                content: Text('Client Has been created'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }
  }

  Clientx client = Clientx('', '', '', '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AdminNavigationDrawerWidget(),
        appBar: AppBar(
          title: const Text("Create Client"),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Form(
                key: _formKey1,
                child: ListView(
                  padding: const EdgeInsets.all(2),
                  //mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        radius: 70,
                        child: ClipOval(
                          child: Image.asset(
                            'images/client.jpg',
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        controller:
                            TextEditingController(text: client.username),
                        onChanged: (value) {
                          client.username = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter something';
                          }
                          return null;
                        },
                        obscureText: false,
                        decoration: InputDecoration(
                            icon: const Icon(Icons.assignment_ind_rounded
                                //color: Colors.orange,
                                ),
                            hintText: 'Client Name',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        controller: TextEditingController(text: client.email),
                        onChanged: (value) {
                          client.email = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter something';
                          } else if (RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            return null;
                          } else {
                            return 'Enter valid email';
                          }
                        },
                        decoration: InputDecoration(
                            icon: const Icon(
                              Icons.email, //color: Colors.orange
                            ),
                            hintText: 'E-mail',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        controller: TextEditingController(text: client.tel),
                        onChanged: (value) {
                          client.tel = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter something';
                          }
                          return null;
                        },
                        // obscureText: true,
                        decoration: InputDecoration(
                            icon: const Icon(
                              Icons.phone,
                              //color: Colors.orange,
                            ),
                            hintText: 'Phone Number',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        controller: TextEditingController(text: client.address),
                        onChanged: (value) {
                          client.address = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter something';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            icon: const Icon(
                              Icons.home, //color: Colors.orange
                            ),
                            hintText: 'Address',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.orange)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.red))),
                      ),
                    ),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.location_city,
                          color: Color.fromARGB(255, 129, 124, 124),
                          size: 20.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CustomDropdownButton2(
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange,
                            ),
                          ),

                          dropdownWidth:
                              200, //MediaQuery.of(context).size.width * 0.3,
                          buttonPadding: const EdgeInsets.all(10.0),
                          scrollbarRadius: const Radius.circular(2),
                          hint: 'City',
                          dropdownItems: City,
                          value: city,
                          buttonHeight: 59,
                          buttonWidth:
                              337, //MediaQuery.of(context).size.width * 0.3,
                          onChanged: (value) {
                            print("below !!!!!!!!!!!!!!");

                            this.setState(() {
                              city = value;
                            });
                          },
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 70,
                        width: 100,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.pink,
                              backgroundColor: Colors.orange,
                            ),
                            /*shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),*/
                            onPressed: () {
                              if (_formKey1.currentState!.validate()) {
                                print("herrrrrrrrrrrrrrrrrrrre");
                                print(city);

                                save();
                              } else {
                                print("not ok");
                              }
                            },
                            child: const Text(
                              "Create",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /*Positioned(
            bottom: 0,
            child: SvgPicture.asset(
              'images/bottom.svg',
              height: 100,
            ))*/
          ],
        ));
  }
}

class Clientx {
  String username;
  String email;
  String tel;
  String address;

  Clientx(
    this.username,
    this.email,
    this.tel,
    this.address,
  );
}
