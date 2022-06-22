import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/Technicien/cpelist.dart';
import 'package:frontend/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'Admin/Admincpelist.dart';
import 'Admin/TechList.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  final navigatorKey = GlobalKey<NavigatorState>();
  String host = "";
  void initState() {
    openHostPopup();
  }

  Future<bool> openHostPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var host = prefs.getString('host');
    if (host == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => new AlertDialog(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red, width: 2)),
          title: Row(children: [
            Icon(CommunityMaterialIcons.server_plus, color: Colors.red),
            SizedBox(width: 5, height: 5),
            Text(
              "Enter your hostname",
              style: TextStyle(fontSize: 15),
            ),
          ]),
          content: TextFormField(
            controller: TextEditingController(text: host),
            onChanged: (value) {
              host = value;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Enter something';
              }
              return null;
            },
            obscureText: false,
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)),
              child: Text("Save"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('host', host.toString());
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ],
        ),
      );
    }
    return true;
  }

  Future save() async {
    //192.168.1.12
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var host = prefs.getString('host').toString();
    print(host);
    var hosst = "https://" + host; //10.0.2.2:8000
    var loginEndPoint = "/api/token/";

    var res = await http.post(Uri.parse(hosst + loginEndPoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': user.email, 'password': user.password}));

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      var token = data['access'];
      var isAdmin = Jwt.parseJwt(token)['is_admin'];
      var email = Jwt.parseJwt(token)['email'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['access']);
      prefs.setString('refreshToken', data['refresh']);
      prefs.setString('email', email);
      prefs.setBool('is_admin', isAdmin);
      if (isAdmin) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const TechList()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CpeList()));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Alert'),
                content: Text('Password or email Invalid'));
          });
    }
  }

  User user = User('', '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            top: 0,
            child: SvgPicture.asset(
              'images/top.svg',
              width: MediaQuery.of(context).size.width,
              height: 150,
            )),
        Container(
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              //mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 150,
                ),
                Center(
                  child: Text(
                    "Signin",
                    style: GoogleFonts.pacifico(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.orange),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: TextEditingController(text: user.email),
                    onChanged: (value) {
                      user.email = value;
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
                        icon: const Icon(Icons.email, color: Colors.orange),
                        hintText: 'Enter Email',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.orange)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.orange)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: TextEditingController(text: user.password),
                    onChanged: (value) {
                      user.password = value;
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
                          color: Colors.orange,
                        ),
                        hintText: 'Enter Password',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.orange)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.orange)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(55, 16, 16, 0),
                  child: SizedBox(
                    height: 70,
                    width: 200,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange,
                          primary: Colors.pink,
                        ),
                        /*shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),*/
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            save();
                          } else {
                            print("not ok");
                          }
                        },
                        child: const Text(
                          "Signin",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  ),
                ),
                /* Padding(
                  padding: const EdgeInsets.fromLTRB(95, 20, 0, 0),
                  child: Row(
                    children: [
                      const Text(
                        "Not have Account ? ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Signup()));
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )*/
                Container(
                  margin: const EdgeInsets.all(40.0),
                  width: 110.0,
                  height: 110.0,
                  alignment: Alignment.center,
                  child: Image.asset('images/orange.jpg'),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }
}
