import 'package:flutter/material.dart';

class MoonCakeModel {
  final String moonCakeID;
  final String moonCakeName;
  final double moonCakePrice;

  MoonCakeModel({
    @required this.moonCakeID,
    @required this.moonCakeName,
    @required this.moonCakePrice,
  });

  Map toJson() => {
        "id": this.moonCakeID,
        "name": this.moonCakeName,
        "price": this.moonCakePrice
      };
}
