import 'package:flutter/material.dart';
import 'package:frontend/Admin/AdminAboutPage.dart';
import 'package:frontend/Admin/Admincpelist.dart';
import 'package:frontend/Admin/ClientList.dart';
import 'package:frontend/Admin/CreateTech.dart';
import 'package:frontend/Admin/TechDetail.dart';
import 'package:frontend/Admin/TechList.dart';
import 'package:frontend/Technicien/cpelist.dart';
import 'package:frontend/signin.dart';

import 'Technicien/AboutPage.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(primaryColor: Color.fromARGB(255, 243, 148, 6)),
      // home: CpeList(title: "MyCpeList")));
      home: Signin()));
}
