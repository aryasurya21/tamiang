import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tamiang/constants/constant.dart';
import 'package:tamiang/helpers/http_exception.dart';
import 'package:tamiang/models/mooncake_model.dart';

class MoonCakesProvider with ChangeNotifier {
  List<MoonCakeModel> _mooncakes;
  final String _authToken;
  final String _userID;

  MoonCakesProvider(this._authToken, this._userID, this._mooncakes);

  List<MoonCakeModel> get mooncakes {
    return this._mooncakes;
  }

  Future<void> fetchMoonCakes([bool filterByUserID = false]) async {
    final filterString =
        filterByUserID ? 'orderBy="creatorID"&equalTo="$_userID"' : '';
    final url =
        "${Constants.baseURL}/mooncakes/${this._userID}.json?auth=${this._authToken}&$filterString";

    try {
      final response = await http.get(url);
      final decodedResponse =
          json.decode(response.body) as Map<String, dynamic>;

      if (decodedResponse == null) {
        return;
      }
      final List<MoonCakeModel> newList = [];
      decodedResponse.forEach((moonCakeID, moonCakeData) {
        newList.add(MoonCakeModel(
          moonCakeID: moonCakeID,
          moonCakeName: moonCakeData["name"],
          moonCakePrice: moonCakeData["price"],
        ));
      });
      this._mooncakes = newList;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addMoonCake(MoonCakeModel model) async {
    final url =
        "${Constants.baseURL}/mooncakes/${this._userID}.json?auth=${this._authToken}";
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "name": model.moonCakeName,
          "price": model.moonCakePrice,
          "creatorID": this._userID
        }),
      );

      final newCake = MoonCakeModel(
        moonCakeID: json.decode(response.body)["name"],
        moonCakeName: model.moonCakeName,
        moonCakePrice: model.moonCakePrice,
      );

      this._mooncakes.add(newCake);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  MoonCakeModel getCakeByID(String moonCakeID) {
    return this
        ._mooncakes
        .firstWhere((element) => element.moonCakeID == moonCakeID);
  }

  Future<void> updateMoonCake(String cakeID, MoonCakeModel model) async {
    final targetIndex =
        this._mooncakes.indexWhere((prod) => prod.moonCakeID == cakeID);
    if (targetIndex >= 0) {
      final url =
          "${Constants.baseURL}/mooncakes/${this._userID}/$cakeID.json?auth=${this._authToken}";
      http.patch(
        url,
        body: json.encode({
          "name": model.moonCakeName,
          "price": model.moonCakePrice,
        }),
      );
      this._mooncakes[targetIndex] = model;
      notifyListeners();
    }
  }

  Future<void> deleteMoonCake(String cakeID) async {
    final url =
        "${Constants.baseURL}/mooncakes/${this._userID}/$cakeID.json?auth=${this._authToken}";
    final existingProductindex =
        this._mooncakes.indexWhere((element) => element.moonCakeID == cakeID);
    var existingProduct = this._mooncakes[existingProductindex];

    this._mooncakes.removeAt(existingProductindex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      this._mooncakes.insert(existingProductindex, existingProduct);
      notifyListeners();
      throw HTTPException("Could not delete product");
    }
    existingProduct = null;
  }
}
