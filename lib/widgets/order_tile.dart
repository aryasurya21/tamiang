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

  Widget _detailContainerCakeOrderPackage(CakePackage orderPackage) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderPackage.mooncake.moonCakeName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        orderPackage.mooncake.moonCakePrice.toString(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "   x${orderPackage.quantity.toString()}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                orderPackage.mooncake.moonCakePrice.toString(),
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
  }

  Widget _detailCardOrderPackage(List<CakePackage> orderPackages) {
    final containers = <Widget>[];
    for (int i = 0; i < orderPackages.length; i++) {
      containers.add(_detailContainerCakeOrderPackage(orderPackages[i]));
    }
    return Container(
      child: Column(
        children: containers,
      ),
    );
  }

  double _generateDiscountedPrice() {
    double discountedPrice =
        this.model.orderDisc / 100 * this.model.orderTotalPrice;
    return this.model.orderTotalPrice - discountedPrice;
  }

  @override
  Widget build(BuildContext context) {
    FlutterMoneyFormatter formattedTotaLPrice = new FlutterMoneyFormatter(
      amount: this.model.orderTotalPrice,
      settings: MoneyFormatterSettings(
        symbol: 'Rp.',
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
        compactFormatType: CompactFormatType.long,
      ),
    );

    FlutterMoneyFormatter _getCurrencyFormat(double price, int qty) {
      FlutterMoneyFormatter formattedTotaLPrice = new FlutterMoneyFormatter(
        amount: price * qty,
        settings: MoneyFormatterSettings(
          symbol: 'Rp.',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 0,
          compactFormatType: CompactFormatType.long,
        ),
      );
      return formattedTotaLPrice;
    }

    final scaffold = Scaffold.of(context);
    return Card(
      elevation: 3,
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
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Yakin?"),
                                content: Text(
                                    "Apakah anda yakin untuk menghapus orderan ini?"),
                                elevation: 3,
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Tidak"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Ya"),
                                    onPressed: () {
                                      try {
                                        Provider.of<OrdersProvider>(context,
                                                listen: false)
                                            .deleteOrder(this.model.orderID);
                                        Navigator.of(context).pop(true);
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
                                  )
                                ],
                              ),
                            );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Persen Diskon'),
                  Text(
                    "${this.model.orderDisc.toStringAsFixed(0)}%",
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
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 10,
              ),
              _detailCardOrderPackage(this.model.orderPackages),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sebelum Diskon",
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
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Setelah Diskon",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _getCurrencyFormat(this._generateDiscountedPrice(), 1)
                        .output
                        .symbolOnLeft
                        .toString(),
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
