import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> removeFromFavourite(String id) async {
  CollectionReference collectionReference =
  FirebaseFirestore.instance.collection('favourite');
  await collectionReference
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("items")
      .doc(id)
      .delete();
}

