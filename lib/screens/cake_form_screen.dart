import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/models/mooncake_model.dart';
import 'package:tamiang/providers/mooncakes_provider.dart';

class CakeFormScreen extends StatefulWidget {
  static const routeName = "order-form";
  CakeFormScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CakeFormScreenState();
}

class _CakeFormScreenState extends State<StatefulWidget> {
  final _priceFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedCake =
      MoonCakeModel(moonCakeID: null, moonCakeName: "", moonCakePrice: 0);
  var _initValues = {"name": "", "price": ""};
  var _isFirstTime = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._isFirstTime) {
      final moonCakeID = ModalRoute.of(context).settings.arguments as String;
      if (moonCakeID != null) {
        this._editedCake =
            Provider.of<MoonCakesProvider>(context, listen: false)
                .getCakeByID(moonCakeID);
        this._initValues = {
          "name": this._editedCake.moonCakeName,
          "price": this._editedCake.moonCakePrice.toString()
        };
      }
      this._isFirstTime = false;
    }
  }

  Future<void> saveData() async {
    final isValid = this._formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      this._isLoading = true;
    });
    this._formKey.currentState.save();
    if (this._editedCake.moonCakeID != null) {
      await Provider.of<MoonCakesProvider>(context)
          .updateMoonCake(this._editedCake.moonCakeID, this._editedCake)
          .then((_) {
        setState(() {
          this._isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      try {
        await Provider.of<MoonCakesProvider>(context)
            .addMoonCake(this._editedCake);
      } catch (err) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text(
                "Something went wrong when adding product: ${err.toString()}"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      } finally {
        setState(() {
          this._isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah/ Edit Kue"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: this.saveData,
          )
        ],
      ),
      body: this._isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: this._formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: this._initValues["name"],
                      decoration: InputDecoration(labelText: "Nama Kue"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(this._priceFocusNode);
                      },
                      onSaved: (newValue) {
                        this._editedCake = MoonCakeModel(
                          moonCakeID: this._editedCake.moonCakeID,
                          moonCakeName: newValue.toString(),
                          moonCakePrice: this._editedCake.moonCakePrice,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Nama kue tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: this._initValues["price"],
                      decoration: InputDecoration(labelText: "Harga Kue"),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(this._priceFocusNode);
                      },
                      onSaved: (newValue) {
                        this._editedCake = MoonCakeModel(
                          moonCakeID: this._editedCake.moonCakeID,
                          moonCakeName: this._editedCake.moonCakeName,
                          moonCakePrice: double.parse(newValue),
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Harga kue tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
