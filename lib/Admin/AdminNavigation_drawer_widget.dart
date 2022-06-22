import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/TechList.dart';
import 'package:frontend/Technicien/AboutPage.dart';
import 'package:frontend/Technicien/cpelist.dart';
import 'package:frontend/signin.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminAboutPage.dart';
import 'Admincpelist.dart';
import 'ClientList.dart';

class AdminNavigationDrawerWidget extends StatefulWidget {
  //final String email, name;
  //const AdminNavigationDrawerWidget(this.email, this.name);

  @override
  State<AdminNavigationDrawerWidget> createState() =>
      _AdminNavigationDrawerWidgetState();
}

class _AdminNavigationDrawerWidgetState
    extends State<AdminNavigationDrawerWidget> {
  void initState() {
    _asyncMethod();
  }

  String email = "", name = "";

  final padding = const EdgeInsets.symmetric(horizontal: 20);
  _asyncMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    this.setState(() {
      email = Jwt.parseJwt(token.toString())['email'];
      name = Jwt.parseJwt(token.toString())['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // const name = "Admin";
    //const email = "admin@gmail.com";
    final image = Image.asset('images/admin2.jpg');
    return Drawer(
      child: Material(
        color: Colors.orange,
        child: ListView(
          children: <Widget>[
            buildHeader(
                image: image,
                name: name, // name: widget.name,

                email: email,
                onClicked: () => selectedItem(context, 0)),
            const SizedBox(height: 18),
            buildMenuItem(
                text: 'My Account',
                icon: Icons.account_box,
                onClicked: () => selectedItem(context, 1)),
            const SizedBox(height: 18),
            const Divider(thickness: 2, color: Colors.white70),
            buildMenuItem(
                text: 'Techniciens',
                icon: Icons.badge_outlined, //work
                onClicked: () => selectedItem(context, 2)),
            const SizedBox(height: 24),
            buildMenuItem(
                text: 'Clients',
                icon: Icons.people,
                onClicked: () => selectedItem(context, 3)),
            const SizedBox(height: 24),
            buildMenuItem(
                text: 'CPEs',
                icon: Icons.router,
                onClicked: () => selectedItem(context, 4)),
            const SizedBox(height: 24),
            const Divider(thickness: 2, color: Colors.white70),
            buildMenuItem(
                text: 'Logout',
                icon: Icons.logout,
                onClicked: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  await prefs.remove('email');
                  await prefs.remove('username');
                  await prefs.remove('is_admin');
                  await prefs.remove('tech_id');

                  selectedItem(context, 5);
                }),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white30;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AboutAdmin(),
        ));
        break;
      case 1:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AboutAdmin(),
        ));
        break;
      case 2:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const TechList(),
        ));
        break;
      case 3:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const ClientList();
          },
        ));
        break;
      case 4:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const AdminCpeList();
          },
        ));
        break;
      case 5:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const Signin();
          },
        ));
        break;
    }
  }

  buildHeader(
          {Image? image,
          String? name,
          String? email,
          Future Function()? onClicked}) =>
      InkWell(
          onTap: onClicked,
          child: Container(
            padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
            child: Row(
              children: [
                CircleAvatar(radius: 30, child: image),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name!,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email!,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ));
}
