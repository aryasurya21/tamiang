import 'package:flutter/material.dart';
import 'package:tamiang/screens/user_cake_screen.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("Hello Mamaku yang cantik"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(
              "Beranda",
              style: TextStyle(fontSize: 17),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              "Pengaturan Kue",
              style: TextStyle(fontSize: 17),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserCakeScreen.routeName);
            },
          )
        ],
      ),
    );
  }
}
