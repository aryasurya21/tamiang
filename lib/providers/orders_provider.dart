import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tamiang/constants/constant.dart';
import 'package:tamiang/helpers/http_exception.dart';
import 'package:tamiang/models/mooncake_model.dart';
import 'package:http/http.dart' as http;

class OrdersProvider with ChangeNotifier {
  List<CakeOrderModel> _orderedCakes;
  final String _userID;
  final String _authToken;

  OrdersProvider(this._authToken, this._userID, this._orderedCakes);

  List<CakeOrderModel> get orderedCakes {
    return this._orderedCakes;
  }

  CakeOrderModel getOrderByID(String orderID) {
    return this
        ._orderedCakes
        .firstWhere((element) => element.orderID == orderID);
  }

  Future<void> updateOrders(String orderID, CakeOrderModel model) async {
    try {
      final targetIndex =
          this._orderedCakes.indexWhere((prod) => prod.orderID == orderID);
      if (targetIndex >= 0) {
        final url =
            "${Constants.baseURL}/orders/${this._userID}/$orderID.json?auth=${this._authToken}";
        http.patch(
          url,
          body: json.encode({
            "name": model.orderName,
            "date": model.orderDate.toString(),
            "orders": model.orderPackages
                .map((op) => {
                      "id": op.packageID,
                      "mooncake": op.mooncake.toJson(),
                      "qty": op.quantity,
                    })
                .toList(),
            "totalprice": model.orderTotalPrice,
            "diskon": model.orderDisc,
          }),
        );
        this._orderedCakes[targetIndex] = model;
        notifyListeners();
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> addOrders(CakeOrderModel model) async {
    try {
      final url =
          "${Constants.baseURL}/orders/${this._userID}.json?auth=${this._authToken}";

      await http
          .post(
        url,
        body: json.encode({
          "name": model.orderName,
          "date": model.orderDate.toString(),
          "orders": model.orderPackages
              .map((op) => {
                    "id": op.packageID,
                    "mooncake": op.mooncake.toJson(),
                    "qty": op.quantity,
                  })
              .toList(),
          "totalprice": model.orderTotalPrice,
          "diskon": model.orderDisc,
        }),
      )
          .then(
        (response) {
          this._orderedCakes.add(
                CakeOrderModel(
                  orderID: json.decode(response.body)["name"],
                  orderName: model.orderName,
                  orderDate: model.orderDate,
                  orderPackages: model.orderPackages,
                  orderTotalPrice: model.orderTotalPrice,
                  orderDisc: model.orderDisc,
                ),
              );
          notifyListeners();
        },
      );
    } catch (err) {
      throw err;
    }
  }

  Future<void> fetchOrders() async {
    try {
      final url =
          "${Constants.baseURL}/orders/${this._userID}.json?auth=${this._authToken}";
      final response = await http.get(url);
      final List<CakeOrderModel> loadedOrders = [];
      final decodedResponse =
          json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse == null) {
        return;
      }
      decodedResponse.forEach((orderID, orderData) {
        loadedOrders.add(CakeOrderModel(
          orderID: orderID,
          orderName: orderData["name"],
          orderDate: DateTime.parse(orderData["date"]),
          orderPackages:
              this.generateOrderData(orderData["orders"] as List<dynamic>),
          orderTotalPrice: orderData["totalprice"],
          orderDisc: orderData["diskon"],
        ));
      });
      this._orderedCakes = loadedOrders;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  List<CakePackage> generateOrderData(List<dynamic> packages) {
    List<CakePackage> generatedList = [];
    for (int i = 0; i < packages.length; i++) {
      generatedList.add(CakePackage(
          packageID: packages[i]["id"],
          mooncake: this.generateCakeModel((packages[i]["mooncake"])),
          quantity: packages[i]["qty"]));
    }

    return generatedList;
  }

  MoonCakeModel generateCakeModel(Map<String, dynamic> cakeDict) {
    MoonCakeModel model = MoonCakeModel(
      moonCakeID: cakeDict["id"],
      moonCakeName: cakeDict["name"],
      moonCakePrice: cakeDict["price"],
    );
    return model;
  }

  Future<void> deleteOrder(String id) async {
    final url =
        "${Constants.baseURL}/orders/${this._userID}/$id.json?auth=${this._authToken}";
    final existingProductindex =
        this._orderedCakes.indexWhere((element) => element.orderID == id);
    var existingProduct = this._orderedCakes[existingProductindex];

    this._orderedCakes.removeAt(existingProductindex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      this._orderedCakes.insert(existingProductindex, existingProduct);
      notifyListeners();
      throw HTTPException("Could not delete product");
    }
    existingProduct = null;
  }
}

class CakeOrderModel with ChangeNotifier {
  final String orderID;
  String orderName;
  DateTime orderDate;
  List<CakePackage> orderPackages;
  double orderTotalPrice;
  double orderDisc;

  CakeOrderModel({
    @required this.orderID,
    @required this.orderName,
    @required this.orderDate,
    @required this.orderPackages,
    @required this.orderTotalPrice,
    @required this.orderDisc,
  });
}

class CakePackage with ChangeNotifier {
  String packageID;
  MoonCakeModel mooncake;
  int quantity;

  CakePackage({
    @required this.packageID,
    @required this.mooncake,
    @required this.quantity,
  });
}
