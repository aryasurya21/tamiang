import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/models/mooncake_model.dart';
import 'package:tamiang/providers/mooncakes_provider.dart';
import 'package:tamiang/providers/orders_provider.dart';
import 'package:uuid/uuid.dart';

class OrderFormScreen extends StatefulWidget {
  static const routeName = "order-form";
  OrderFormScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<StatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  static var uuid = Uuid();
  var _editedOrder = CakeOrderModel(
      orderDate: null,
      orderID: null,
      orderName: null,
      orderPackages: [],
      orderTotalPrice: null);
  Map<String, String> _initValues = {"name": "", "date": ""};
  var _packageCards = <Dismissible>[];
  var _isFirstTime = true;
  var _isLoading = false;
  List<CakePackage> selectedMoonCakes = [
    CakePackage(mooncake: null, quantity: null, packageID: uuid.v1().toString())
  ];
  List<MoonCakeModel> moonCakeList = [];
  var _numberOfPackages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._isFirstTime) {
      final orderID = ModalRoute.of(context).settings.arguments as String;
      if (orderID != null) {
        this._editedOrder = Provider.of<OrdersProvider>(context, listen: false)
            .getOrderByID(orderID);
        this._initValues = {
          "name": this._editedOrder.orderName,
          "date": this._editedOrder.orderDate.toString()
        };
      }
      Provider.of<MoonCakesProvider>(context).fetchMoonCakes().then((_) {
        this.moonCakeList = Provider.of<MoonCakesProvider>(context).mooncakes;
        this._packageCards.add(createCard(0));
      });
      this._isFirstTime = false;
    }
  }

  Widget createCard(final index) {
    return Dismissible(
      key: ValueKey(index),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.all(10),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Yakin?"),
            content: Text("Apakah anda yakin untuk menghapus kue ini?"),
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
                  Navigator.of(context).pop(true);
                },
              )
            ],
          ),
        );
      },
      onDismissed: (_) {
        setState(() {});
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              _dropdownbutton(this.moonCakeList, index),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("x"),
              ),
              Container(
                  width: 20,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value != "") {
                        this.selectedMoonCakes[index].quantity =
                            int.parse(value);
                      }
                      print(this.selectedMoonCakes);
                    },
                  )),
              Text("Kotak")
            ],
          ),
        ),
      ),
    );
  }

  double calculateTotalPrice(List<CakePackage> list) {
    double totalPrice = 0;
    list.forEach((element) {
      totalPrice += (element.mooncake.moonCakePrice * element.quantity);
    });
    return totalPrice;
  }

  Widget _dropdownbutton(List<MoonCakeModel> mooncakeList, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(
          Radius.circular(25.0),
        ),
      ),
      child: DropdownButton<MoonCakeModel>(
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down),
        hint: Text("Pilih kue"),
        value: selectedMoonCakes[index].mooncake,
        onChanged: (MoonCakeModel value) {
          print(value.toString());
          print(index);
          setState(() {
            selectedMoonCakes[index].mooncake = value;
          });
        },
        items: mooncakeList.map((MoonCakeModel model) {
          return DropdownMenuItem<MoonCakeModel>(
            value: model,
            child: Row(
              children: <Widget>[
                Text(
                  model.moonCakeName,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> saveData() async {
    final isValid = this._formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    this._editedOrder.orderPackages = this.selectedMoonCakes;
    this._editedOrder.orderTotalPrice =
        this.calculateTotalPrice(this.selectedMoonCakes);
    setState(() {
      this._isLoading = true;
    });
    this._formKey.currentState.save();
    if (this._editedOrder.orderID != null) {
      await Provider.of<OrdersProvider>(context)
          .updateOrders(this._editedOrder.orderID, this._editedOrder)
          .then((_) {
        setState(() {
          this._isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      try {
        await Provider.of<OrdersProvider>(context).addOrders(this._editedOrder);
      } catch (err) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text(
                "Something went wrong when adding product: ${err.toString()}"),
            actions: <Widget>[
              RaisedButton(
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

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        this._editedOrder = CakeOrderModel(
            orderDate: pickedDate,
            orderID: this._editedOrder.orderID,
            orderName: this._editedOrder.orderName,
            orderPackages: this._editedOrder.orderPackages,
            orderTotalPrice: this._editedOrder.orderTotalPrice);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah/ Edit Orderan"),
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
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: this._initValues["name"],
                        decoration: InputDecoration(labelText: "Nama Pemesan"),
                        textInputAction: TextInputAction.next,
                        onChanged: (newValue) {
                          this._editedOrder = CakeOrderModel(
                            orderDate: this._editedOrder.orderDate,
                            orderID: this._editedOrder.orderID,
                            orderName: newValue,
                            orderPackages: this._editedOrder.orderPackages,
                            orderTotalPrice: this._editedOrder.orderTotalPrice,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Nama Pelanggan tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        height: 70,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(this._editedOrder.orderDate == null
                                  ? "Tidak ada tanggal terpilih"
                                  : "Tanggal Orderan: ${DateFormat().add_yMMMMd().format(this._editedOrder.orderDate)}"),
                            ),
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                "Pilih Tanggal Order",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: this._presentDatePicker,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: this._numberOfPackages,
                          itemBuilder: (BuildContext context, int index) {
                            return this.createCard(index);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                side: BorderSide(color: Colors.red)),
                            elevation: 4,
                            color: Colors.red,
                            textColor: Colors.white,
                            child: Text(
                              "Tambah Kue di Pesanan",
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              this._numberOfPackages++;
                              this.selectedMoonCakes.add(
                                    CakePackage(
                                      mooncake: null,
                                      quantity: null,
                                      packageID: uuid.v1().toString(),
                                    ),
                                  );
                              setState(() {});
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
