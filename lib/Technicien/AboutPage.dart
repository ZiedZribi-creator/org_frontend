import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Technicien/cpelist.dart';
import 'package:frontend/Technicien/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

//String email = '', name = '';

Future<Tech> _getTech() async {
  late Tech tech;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  var host = prefs.getString('host').toString();

  var tech_id = Jwt.parseJwt(token.toString())['tech_id'];
  //email = Jwt.parseJwt(token.toString())['email'];
  //name = Jwt.parseJwt(token.toString())['username'];
  print("heeeeeeeeeeeeeeeeeere");
  print(tech_id);
  //var host = "efbf-102-25-171-90.eu.ngrok.io";
  var tekDetailEndPoint = "/api/tek/" + tech_id.toString();
  var response = await http.get(
    Uri.https(host,
        tekDetailEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 401) {
    //refresh token and call getUser again
    var refreshToken = prefs.getString('refreshToken');
    var host = "https://efbf-102-25-171-90.eu.ngrok.io";
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
    var tekDetail = jsonDecode(response.body);
    print("tekDetail ::::::::::::::::::::");
    print(tekDetail);
    tech = Tech(tekDetail['email'], tekDetail['username'], tekDetail['tel'],
        tekDetail['city'], tekDetail['working_city'], tekDetail['id']);
  }
  print(tech.email);
  return tech;
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
            backgroundColor: Colors.orange,
            title: Center(child: Text("Profile details"))),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 20, 5, 50),
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 70,
                    child: ClipOval(
                      child: Image.asset(
                        'images/technicien2.jpg',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ))
                ],
              ),
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10.8),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color.fromARGB(255, 255, 153, 1),
                                Color.fromARGB(255, 240, 185, 103)
                              ])),
                      child: FutureBuilder<Tech>(
                          future: _getTech(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            print("belowwwwwwwwwwwww");
                            print(snapshot.data);
                            if (snapshot.data == null) {
                              return Container(
                                  child:
                                      const Center(child: Text("Loading...")));
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 25, 20, 4),
                                    child: Container(
                                      height: 60,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "email:   " + snapshot.data.email,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    179, 0, 0, 0)),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              207, 255, 255, 255),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.white70)),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 20, 4),
                                    child: Container(
                                      height: 60,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "username:    " +
                                                snapshot.data.username,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    179, 0, 0, 0)),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              207, 255, 255, 255),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.white70)),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 20, 4),
                                    child: Container(
                                      height: 60,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "phone number:    " +
                                                snapshot.data.tel,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    179, 0, 0, 0)),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              207, 255, 255, 255),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.white70)),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 20, 4),
                                    child: Container(
                                      height: 60,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "city:     " + snapshot.data.city,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    179, 0, 0, 0)),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              207, 255, 255, 255),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.white70)),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 20, 4),
                                    child: Container(
                                      height: 60,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "working city:    " +
                                                snapshot.data.working_city,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    179, 0, 0, 0)),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              207, 255, 255, 255),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.white70)),
                                    ),
                                  ),
                                ],
                              );
                            }
                            ;
                          }),
                    )))
          ],
        ));
  }
}

class Tech {
  final String email;
  final String username;
  final String tel;
  final String city;
  final String working_city;
  final int id;

  Tech(this.email, this.username, this.tel, this.city, this.working_city,
      this.id);
}
