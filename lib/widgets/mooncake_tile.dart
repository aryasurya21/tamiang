import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/mooncakes_provider.dart';
import 'package:tamiang/screens/cake_form_screen.dart';

class MoonCakeTile extends StatelessWidget {
  final int position;
  final String moonCakeID;
  final String moonCakeName;
  final double moonCakePrice;

  MoonCakeTile(
      this.position, this.moonCakeID, this.moonCakeName, this.moonCakePrice);

  @override
  Widget build(BuildContext context) {
    FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
      amount: this.moonCakePrice,
      settings: MoneyFormatterSettings(
          symbol: 'Rp',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 0,
          compactFormatType: CompactFormatType.long),
    );

    final scaffold = Scaffold.of(context);
    return Card(
      child: ListTile(
        title: Text(
          this.moonCakeName,
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
                    CakeFormScreen.routeName,
                    arguments: this.moonCakeID,
                  );
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Yakin?"),
                      content:
                          Text("Apakah anda yakin untuk menghapus kue ini?"),
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
                              Provider.of<MoonCakesProvider>(context,
                                      listen: false)
                                  .deleteMoonCake(this.moonCakeID);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
