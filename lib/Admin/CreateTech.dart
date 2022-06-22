import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/Admin/AdminNavigation_drawer_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Technicien/CustomDropdownButton.dart';
import 'TechList.dart';

final _formKey = GlobalKey<FormState>();
final navigatorKey = GlobalKey<NavigatorState>();

class CreateTech extends StatefulWidget {
  const CreateTech({Key? key}) : super(key: key);

  @override
  _CreateTechState createState() => _CreateTechState();
}

class _CreateTechState extends State<CreateTech> {
  final List<String> Working_city = [
    'Ariana',
    'Tunis',
    'Ben Arous',
    'Manouba',
  ];
  //String email = '', name = '';

  String? working_city;
  String? city;

  @override
  void initState() {
    String? working_city;
    String? city;
  }

  Future save() async {
    //192.168.1.12
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var host = prefs.getString('host').toString();
    var hosst = "https://" + host; //10.0.2.2:8000
    var create_tech_end_point = "/api/tech/";
    var token = prefs.getString('token');
    //email = Jwt.parseJwt(token.toString())['email'];
    //name = Jwt.parseJwt(token.toString())['username'];
    setState(() {});
    var res = await http.post(Uri.parse(hosst + create_tech_end_point),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': tech.username,
          'email': tech.email,
          'tel': tech.tel,
          'city': city,
          'working_city': working_city,
          'password': tech.password
        }));

    if (res.statusCode == 201) {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => TechList()));
    }
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
              title: Text('Succes'), content: Text('Tech Has been created'));
        });
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    });
  }

  Tech tech = Tech('', '', '', '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AdminNavigationDrawerWidget(),
        appBar: AppBar(
          title: const Text("Create Tech"),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Form(
                key: _formKey,
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
                            'images/tech2.jpg',
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
                        controller: TextEditingController(text: tech.username),
                        onChanged: (value) {
                          tech.username = value;
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
                            hintText: 'Tech Name',
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
                        controller: TextEditingController(text: tech.email),
                        onChanged: (value) {
                          tech.email = value;
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
                        controller: TextEditingController(text: tech.password),
                        onChanged: (value) {
                          tech.password = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter something';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            icon: const Icon(
                              Icons.vpn_key,
                              //color: Colors.orange,
                            ),
                            hintText: 'Enter Password',
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
                        controller: TextEditingController(text: tech.tel),
                        onChanged: (value) {
                          tech.tel = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter something';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            icon: const Icon(
                              Icons.phone, //color: Colors.orange
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
                          dropdownItems: Working_city,
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
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.work_outline_outlined,
                          color: Colors.grey,
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
                          hint: 'Working City',
                          dropdownItems: Working_city,
                          value: working_city,
                          buttonHeight: 59,
                          buttonWidth:
                              337, //MediaQuery.of(context).size.width * 0.3,
                          onChanged: (value) {
                            print("below !!!!!!!!!!!!!!");

                            this.setState(() {
                              working_city = value;
                            });
                          },
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 55,
                        width: 70,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.pink,
                              backgroundColor: Colors.orange,
                            ),
                            /*shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),*/
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                print("herrrrrrrrrrrrrrrrrrrre");
                                print(working_city);

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

class Tech {
  String username;
  String email;
  String tel;
  String password;

  Tech(
    this.username,
    this.email,
    this.tel,
    this.password,
  );
}
