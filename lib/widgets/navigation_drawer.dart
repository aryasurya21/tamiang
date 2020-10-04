import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/auth_provider.dart';
import 'package:tamiang/screens/user_cake_screen.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userID = Provider.of<AuthProvider>(context).userID;
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: userID == null
                ? "Hello... "
                : userID.startsWith("XSlN")
                    ? Text("Hello Mamaku yang cantik")
                    : Text("Hello.."),
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
          ),
        ],
      ),
    );
  }
}
