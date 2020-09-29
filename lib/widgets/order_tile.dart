import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/orders_provider.dart';
import 'package:tamiang/screens/order_form_screen.dart';

class OrderTile extends StatelessWidget {
  final int position;
  final CakeOrderModel model;

  OrderTile(this.position, this.model);

  @override
  Widget build(BuildContext context) {
    FlutterMoneyFormatter formattedTotaLPrice = new FlutterMoneyFormatter(
      amount: this.model.orderTotalPrice,
      settings: MoneyFormatterSettings(
          symbol: 'Rp',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 0,
          compactFormatType: CompactFormatType.long),
    );

    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(
        this.model.orderName,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Column(
          children: <Widget>[
            Text(formattedTotaLPrice.output.symbolOnLeft.toString(),
                style: TextStyle(fontSize: 15)),
            Expanded(
              child: ListView.builder(
                itemCount: this.model.orderPackages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Text(
                          this.model.orderPackages[index].mooncake.moonCakeName,
                        ),
                        Row(
                          children: <Widget>[
                            Text(this
                                .model
                                .orderPackages[index]
                                .mooncake
                                .moonCakePrice
                                .toString()),
                            Text("x"),
                            Text(this
                                .model
                                .orderPackages[index]
                                .quantity
                                .toString())
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      leading: Text(this.position.toString()),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  OrderFormScreen.routeName,
                  arguments: this.model.orderID,
                );
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<OrdersProvider>(context, listen: false)
                      .deleteOrder(this.model.orderID);
                } catch (err) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content:
                          Text("Gagal ketika menghapus, silahkan coba lagi."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}
