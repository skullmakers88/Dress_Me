import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/widgets/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../product_detail_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<String> ids = [];

  Future<void> _getId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favourite')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('items')
        .get();

    setState(() {
      ids = snapshot.docs.map((doc) => doc['pid'].toString()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Automatically refresh data when the screen is opened
  }

  Future<void> _refreshData() async {
    await _getId(); // Refresh the data by calling _getId again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: Header(
          title: "FAVOURITE",
        ),
      ),
      body: FutureBuilder<void>(
        future: _getId(), // Fetch favorite item IDs during the initial build
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Center(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final favoriteProducts = snapshot.data!.docs
                      .where((element) => ids.contains(element["id"].toString()))
                      .toList();

                  if (favoriteProducts.isEmpty) {
                    return Center(child: Text("No Favorite Items Found"));
                  }

                  return ListView.builder(
                    itemCount: favoriteProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final product = favoriteProducts[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.7.h),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  id: product['id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Image.network(
                                  product['imageUrls'][0], // Replace with the correct field name
                                  width: 50.0, // Adjust the size as needed
                                  height: 50.0,
                                ),
                                title: Text(
                                  product['productName'],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.navigate_next_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

