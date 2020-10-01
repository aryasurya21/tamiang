import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/orders_provider.dart';
import 'package:tamiang/screens/order_form_screen.dart';
import 'package:tamiang/screens/cake_form_screen.dart';
import 'package:tamiang/widgets/navigation_drawer.dart';
import 'package:tamiang/widgets/order_tile.dart';

class UserOrderScreen extends StatefulWidget {
  @override
  _UserOrderScreenState createState() => _UserOrderScreenState();
}

class _UserOrderScreenState extends State<UserOrderScreen> {
  Future<void> _refreshData(BuildContext context) async {
    try {
      await Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    } catch (err) {
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pesanan"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(OrderFormScreen.routeName);
              },
            )
          ],
        ),
        drawer: NavigationDrawer(),
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
                      child: Consumer<OrdersProvider>(
                        builder: (context, orders, child) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Column(
                                  children: <Widget>[
                                    OrderTile(
                                      index + 1,
                                      orders.orderedCakes[index],
                                    ),
                                  ],
                                );
                              },
                              itemCount: orders.orderedCakes.length,
                            ),
                          );
                        },
                      ),
                    ),
        ));
  }
}
