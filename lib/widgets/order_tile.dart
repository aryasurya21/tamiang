import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/orders_provider.dart';
import 'package:tamiang/screens/order_form_screen.dart';

class OrderTile extends StatelessWidget {
  final int position;
  final String orderID;
  final String ordererName;
  final double orderTotalPrice;

  OrderTile(
      this.position, this.orderID, this.ordererName, this.orderTotalPrice);

  @override
  Widget build(BuildContext context) {
    FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
      amount: this.orderTotalPrice,
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
        this.ordererName,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        fmf.output.symbolOnLeft.toString(),
        style: TextStyle(fontSize: 15),
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
                  arguments: this.orderID,
                );
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<OrdersProvider>(context, listen: false)
                      .deleteOrder(this.orderID);
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
