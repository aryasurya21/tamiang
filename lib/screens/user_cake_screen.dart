import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/mooncakes_provider.dart';
import 'package:tamiang/screens/cake_form_screen.dart';
import 'package:tamiang/widgets/mooncake_tile.dart';
import 'package:tamiang/widgets/navigation_drawer.dart';

class UserCakeScreen extends StatelessWidget {
  static const routeName = "/user-cake";

  Future<void> _refreshData(BuildContext context) async {
    try {
      await Provider.of<MoonCakesProvider>(context, listen: false)
          .fetchMoonCakes(true);
    } catch (err) {
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      drawer: NavigationDrawer(),
      appBar: AppBar(
        title: Text("Daftar Kue Anda"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(CakeFormScreen.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: this._refreshData(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  )
                : RefreshIndicator(
                    backgroundColor: Colors.red,
                    onRefresh: () => this._refreshData(context),
                    child: Consumer<MoonCakesProvider>(
                      builder: (context, mooncakes, _) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  MoonCakeTile(
                                    index + 1,
                                    mooncakes.mooncakes[index].moonCakeID,
                                    mooncakes.mooncakes[index].moonCakeName,
                                    mooncakes.mooncakes[index].moonCakePrice,
                                  ),
                                ],
                              );
                            },
                            itemCount: mooncakes.mooncakes.length,
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
