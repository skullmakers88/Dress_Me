import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Cart {
  String? id;
  String? name;
  String? image;
  Cart({
    @required this.id,
    @required this.image,
    @required this.name,
  });

  static Future<void> addtoCart(Cart cart) async {
    CollectionReference db = FirebaseFirestore.instance.collection("favourite");
    Map<String, dynamic> data = {
      "id": cart.id,
      "productName": cart.name,
      "image": cart.image,
    };
    await db.add(data);
  }
}
