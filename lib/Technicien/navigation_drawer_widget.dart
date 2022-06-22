import 'package:flutter/material.dart';
import 'package:frontend/Technicien/AboutPage.dart';
import 'package:frontend/Technicien/cpelist.dart';
import 'package:frontend/signin.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_material_icon/community_material_icon.dart';

class NavigationDrawerWidget extends StatefulWidget {
  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
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
    //const name = "Technicien";
    //const email = "tech@gmail.com";
    final image = Image.asset('images/technicien2.jpg');

    return Drawer(
      child: Material(
        color: Colors.orange,
        child: ListView(
          children: <Widget>[
            buildHeader(
                image: image,
                name: name,
                email: email,
                onClicked: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ))),
            const SizedBox(height: 18),
            buildMenuItem(
                text: 'My Account',
                icon: Icons.account_box,
                onClicked: () => selectedItem(context, 0)),
            const SizedBox(height: 18),
            buildMenuItem(
                text: 'My Cpes',
                icon: Icons.router,
                onClicked: () => selectedItem(context, 1)),
            const SizedBox(height: 24),
            const Divider(thickness: 2, color: Colors.white70),
            const SizedBox(height: 18),
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

                  selectedItem(context, 2);
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
          builder: (context) => AboutPage(),
        ));
        break;
      case 1:
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const CpeList(),
        ));
        break;
      case 2:
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
