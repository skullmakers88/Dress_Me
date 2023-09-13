import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class fav {
  String? id;
  String? name;

  String? image;
  fav({
    @required this.id,
    @required this.image,
    @required this.name,

  });

  static Future<void> addtofav(fav fav) async {
    CollectionReference db = FirebaseFirestore.instance.collection("cart");
    Map<String, dynamic> data = {
      "id": fav.id,
      "productName": fav.name,
      "image": fav.image,
    };
    await db.add(data);
  }
}
