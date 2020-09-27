import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tamiang/constants/constant.dart';
import 'package:tamiang/helpers/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userID;
  Timer _authTimer;

  bool get isAuth {
    return this.token != null;
  }

  String get token {
    if (this._expireDate != null &&
        this._expireDate.isAfter(DateTime.now()) &&
        this._token != null) {
      return this._token;
    }
    return null;
  }

  String get userID {
    return this._userID;
  }

  Future<void> login(String email, String password) async {
    String loginURL = "${Constants.loginURL}${Constants.apiKey}";

    try {
      final response = await http.post(
        loginURL,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      var decodedData = json.decode(response.body);
      if (decodedData["error"] != null) {
        throw HTTPException(decodedData["error"]["message"]);
      }
      this._token = decodedData["idToken"];
      this._userID = decodedData["localId"];
      this._expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(decodedData["expiresIn"])));
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": this._token,
        "userID": this._userID,
        "expiryDate": this._expireDate.toString()
      });
      prefs.setString("creds", userData);
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("creds")) {
      return false;
    }
    final decodedCred =
        json.decode(prefs.getString("creds")) as Map<String, Object>;
    final expiryDate = DateTime.parse(decodedCred["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    this._token = decodedCred["token"];
    this._userID = decodedCred["userID"];
    this._expireDate = DateTime.parse(decodedCred["expiryDate"]);
    this._setupAutoLogout();
    return true;
  }

  Future<void> logout() async {
    this._token = null;
    this._userID = null;
    this._expireDate = null;
    if (this._authTimer != null) {
      this._authTimer.cancel();
      this._authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _setupAutoLogout() {
    if (this._authTimer != null) {
      this._authTimer.cancel();
    }
    final timeToExpiry = this._expireDate.difference(DateTime.now()).inSeconds;
    this._authTimer = Timer(Duration(seconds: timeToExpiry), this.logout);
  }
}
