import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
        compactFormatType: CompactFormatType.long,
      ),
    );

    final scaffold = Scaffold.of(context);
    return Card(
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    this.model.orderName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
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
                              await Provider.of<OrdersProvider>(context,
                                      listen: false)
                                  .deleteOrder(this.model.orderID);
                            } catch (err) {
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Gagal ketika menghapus, silahkan coba lagi."),
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tanggal Order'),
                  Text(
                      "${DateFormat().add_yMMMMd().format(this.model.orderDate)}"),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.red,
              ),
              Container(
                height: this.model.orderPackages.length.toDouble() * 40,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: this.model.orderPackages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        this
                                            .model
                                            .orderPackages[index]
                                            .mooncake
                                            .moonCakeName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        this
                                            .model
                                            .orderPackages[index]
                                            .mooncake
                                            .moonCakePrice
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "   x${this.model.orderPackages[index].quantity.toString()}",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                this
                                    .model
                                    .orderPackages[index]
                                    .mooncake
                                    .moonCakePrice
                                    .toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(
                color: Colors.red,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Total    ",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formattedTotaLPrice.output.symbolOnLeft.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
