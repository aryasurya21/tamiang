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

  Future<void> updateOrders(String orderID, CakeOrderModel model) {
    try {
      final targetIndex =
          this._orderedCakes.indexWhere((prod) => prod.orderID == orderID);
      if (targetIndex >= 0) {
        final url =
            "${Constants.baseURL}/orders/${this._userID}.json?auth=${this._authToken}";
        http.patch(
          url,
          body: json.encode({
            "name": model.orderName,
            "date": model.orderDate.toString(),
            "orders": model.orderPackages,
            "totalprice": model.orderTotalPrice
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
      final response = await http.post(
        url,
        body: json.encode({
          "name": model.orderName,
          "date": model.orderDate.toString(),
          "orders": model.orderPackages,
          "totalprice": model.orderTotalPrice
        }),
      );

      this._orderedCakes.insert(
          0,
          CakeOrderModel(
            orderID: json.decode(response.body)["id"],
            orderName: model.orderName,
            orderDate: model.orderDate,
            orderPackages: model.orderPackages,
            orderTotalPrice: model.orderTotalPrice,
          ));
      notifyListeners();
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
      if (decodedResponse != null) {
        return;
      }
      decodedResponse.forEach((orderID, orderData) {
        loadedOrders.add(CakeOrderModel(
          orderID: orderID,
          orderName: orderData["name"],
          orderDate: DateTime.parse(orderData["date"]),
          orderPackages: this.generateOrderData(
              orderData["orders"] as List<Map<String, dynamic>>),
          orderTotalPrice: orderData["totalprice"],
        ));
      });
      this._orderedCakes = loadedOrders;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  List<CakePackage> generateOrderData(List<Map<String, dynamic>> packages) {
    List<CakePackage> generatedList = [];
    for (int i = 0; i < packages.length - 1; i++) {
      packages[i].forEach((packageID, packageData) {
        generatedList.add(CakePackage(
          packageID: packageID,
          mooncake: this.generateCakeModel(packageData["cake"]),
          quantity: packageData["qty"],
        ));
      });
    }
    return generatedList;
  }

  MoonCakeModel generateCakeModel(Map<String, dynamic> cakeDict) {
    MoonCakeModel model;
    cakeDict.forEach((moonCakeID, moonCakeData) {
      model = MoonCakeModel(
        moonCakeID: moonCakeID,
        moonCakeName: moonCakeData["name"],
        moonCakePrice: moonCakeData["price"],
      );
    });
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
  final String orderName;
  final DateTime orderDate;
  final List<CakePackage> orderPackages;
  final double orderTotalPrice;

  CakeOrderModel({
    @required this.orderID,
    @required this.orderName,
    @required this.orderDate,
    @required this.orderPackages,
    @required this.orderTotalPrice,
  });
}

class CakePackage with ChangeNotifier {
  final String packageID;
  final MoonCakeModel mooncake;
  final int quantity;

  CakePackage({
    @required this.packageID,
    @required this.mooncake,
    @required this.quantity,
  });
}
