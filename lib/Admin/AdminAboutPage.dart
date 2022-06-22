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

class AboutAdmin extends StatefulWidget {
  const AboutAdmin({Key? key}) : super(key: key);

  @override
  _AboutAdminState createState() => _AboutAdminState();
}

class _AboutAdminState extends State<AboutAdmin> {
  //String email = '', name = '';
  late Future<UpdateAdmin> updateAdmin;
  late UpdateAdmin updateAdmin_h;
  final _formKey1 = GlobalKey<FormState>();
  final navigatorKey = GlobalKey<NavigatorState>();
  final List<String> City = [
    '____',
    'Ariana',
    'Tunis',
    'Ben Arous',
    'Manouba',
  ];
  String? city;

  @override
  void initState() {
    updateAdmin = getAdmin();
  }

  Future<UpdateAdmin> getAdmin() async {
    //late Clienty client;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var admin_id = Jwt.parseJwt(token.toString())['user_id'];
    var host = prefs.getString('host').toString();

    //email = Jwt.parseJwt(token.toString())['email'];
    //name = Jwt.parseJwt(token.toString())['username'];
    //setState(() {});
    print("admin_id : $admin_id");
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var adminDetailEndPoint = "api/admin/" + admin_id.toString() + '/';
    print("adminDetailEndPoint : $adminDetailEndPoint");
    var response = await http.get(
      Uri.https(host,
          adminDetailEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
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
      var adminDetail = jsonDecode(response.body);
      updateAdmin_h = UpdateAdmin(
          adminDetail['username'], adminDetail['email'], '', '', '');
      return updateAdmin_h;
    }

    return updateAdmin_h;
  }

  Future _updateAdmin() async {
    //192.168.1.12
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    //print(Jwt.parseJwt(token.toString()));
    var admin_id = Jwt.parseJwt(token.toString())['user_id'];
    var host = prefs.getString('host').toString();

    var hosst = "https://" + host; //10.0.2.2:8000

    var adminDetailEndPoint = "/api/admin/" + admin_id.toString() + '/update/';
    print(adminDetailEndPoint);

    var res = await http.put(Uri.parse(hosst + adminDetailEndPoint),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': updateAdmin_h.username,
          'email': updateAdmin_h.email,
          'new_password': updateAdmin_h.new_password,
          'confirm_new_password': updateAdmin_h.confirm_new_password,
          'old_password': updateAdmin_h.old_password,
          'user_id': admin_id
          //'clien_id': 0
        }));

    if (res.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'), content: Text('Admin Has been updated'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }
    if (res.statusCode == 401) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('ERROR'), content: Text('Invalid old password'));
          });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AdminNavigationDrawerWidget(),
        appBar: AppBar(
          title: const Text(" Admin Account"),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Form(
                key: _formKey1,
                child: FutureBuilder(
                    future: updateAdmin,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      print(snapshot.data);
                      if (snapshot.data == null) {
                        return Container(
                            child: const Center(child: Text("Loading...")));
                      } else {
                        return ListView(
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
                                    'images/admin2.jpg',
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
                                controller: TextEditingController(
                                    text: updateAdmin_h.username),
                                onChanged: (value) {
                                  updateAdmin_h.username = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter something';
                                  }
                                  return null;
                                },
                                obscureText: false,
                                decoration: InputDecoration(
                                    icon:
                                        const Icon(Icons.assignment_ind_rounded
                                            //color: Colors.orange,
                                            ),
                                    hintText: 'Name',
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                controller: TextEditingController(
                                    text: updateAdmin_h.email),
                                onChanged: (value) {
                                  updateAdmin_h.email = value;
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
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                obscureText: true,
                                controller: TextEditingController(
                                    text: updateAdmin_h.new_password),
                                onChanged: (value) {
                                  updateAdmin_h.new_password = value;
                                },
                                validator: (value) {
                                  return null;
                                  if (value!.isEmpty) {
                                    return 'Enter something';
                                  }
                                  return null;
                                },
                                // obscureText: true,
                                decoration: InputDecoration(
                                    icon: const Icon(
                                      Icons.password_sharp,
                                      //color: Colors.orange,
                                    ),
                                    hintText: 'New Password',
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                obscureText: true,
                                controller: TextEditingController(
                                    text: updateAdmin_h.confirm_new_password),
                                onChanged: (value) {
                                  updateAdmin_h.confirm_new_password = value;
                                },
                                validator: (value) {
                                  if (updateAdmin_h
                                          .confirm_new_password!.isEmpty ==
                                      false) {
                                    if (updateAdmin_h.new_password!.isEmpty ==
                                        false) {
                                      if (updateAdmin_h.new_password !=
                                          updateAdmin_h.confirm_new_password) {
                                        return 'new password should match the confirm new password';
                                      }
                                    } else {
                                      return "new password is required";
                                    }
                                  }

                                  return null;
                                },
                                decoration: InputDecoration(
                                    icon: const Icon(Icons
                                            .password_rounded //color: Colors.orange
                                        ),
                                    hintText: 'Confirm New Password',
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                obscureText: true,
                                controller: TextEditingController(
                                    text: updateAdmin_h.old_password),
                                onChanged: (value) {
                                  updateAdmin_h.old_password = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter something';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    icon: const Icon(Icons
                                            .password_rounded //color: Colors.orange
                                        ),
                                    hintText: 'Old Password',
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.orange)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Colors.red))),
                              ),
                            ),
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
                                        borderRadius:
                                            BorderRadius.circular(10.0)),*/
                                    onPressed: () {
                                      if (_formKey1.currentState!.validate()) {
                                        print("herrrrrrrrrrrrrrrrrrrre");
                                        //print(city);

                                        _updateAdmin();
                                      } else {
                                        print("not ok");
                                      }
                                    },
                                    child: const Text(
                                      "Update",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
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

class UpdateAdmin {
  String? username;
  String? email;
  String? new_password;
  String? confirm_new_password;
  String? old_password;

  UpdateAdmin(this.username, this.email, this.new_password,
      this.confirm_new_password, this.old_password);
}
