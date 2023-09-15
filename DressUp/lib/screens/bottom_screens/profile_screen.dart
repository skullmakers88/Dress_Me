import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../product_detail_screen.dart';

class MyUploadsScreen extends StatefulWidget {
  const MyUploadsScreen({Key? key}) : super(key: key);

  @override
  State<MyUploadsScreen> createState() => _MyUploadsScreenState();
}

class _MyUploadsScreenState extends State<MyUploadsScreen> {
  late User _user;
  late Stream<QuerySnapshot> _userUploadsStream;
  List<Map<String, dynamic>> _userUploads = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _userUploadsStream = FirebaseFirestore.instance
        .collection('products')
        .where('uploaderId', isEqualTo: _user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: AppBar(
          title: Text("MY UPLOADS"),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userUploadsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No uploads available.'),
            );
          } else {
            final products = snapshot.data!.docs;
            _userUploads =
                products.map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
            return ListView(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _createRandomOutfit();
                  },
                  child: Text('Create Random Outfit'),
                ),
                SizedBox(height: 10),
                ..._userUploads.map((product) {
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
                              product['imageUrls'][0],
                              width: 50.0,
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
                }).toList(),
              ],
            );
          }
        },
      ),
    );
  }

  void _createRandomOutfit() {
    if (_userUploads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No uploads available to create an outfit.'),
      ));
      return;
    }

    final selectedProducts = <Map<String, dynamic>>{};

    for (int i = 0; i < 3; i++) {
      final randomProduct = _userUploads[Random().nextInt(_userUploads.length)];
      selectedProducts.add(randomProduct);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String outfitName = '';
        String outfitImageUrl = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Generated Outfit'),
              content: Container(
                width: 300.0, // Set the width to your desired value
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedProducts.length,
                        itemBuilder: (context, index) {
                          final product = selectedProducts.elementAt(index);
                          return ListTile(
                            title: Text(product['productName']),
                            leading: Image.network(
                              product['imageUrls'][0],
                              width: 50.0,
                              height: 50.0,
                            ),
                          );
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Outfit Name'),
                        onChanged: (value) {
                          setState(() {
                            outfitName = value;
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        onChanged: (value) {
                          setState(() {
                            outfitImageUrl = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _saveOutfitToFavorites(
                      selectedProducts,
                      outfitName,
                      outfitImageUrl,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Save to Favorites'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _saveOutfitToFavorites(
      Set<Map<String, dynamic>> selectedProducts,
      String outfitName,
      String outfitImageUrl,
      ) {
    final List<String> productIds = selectedProducts
        .map((product) => product['id'] as String)
        .toList();

    final outfit = OutfitModel(
      id: UniqueKey().toString(),
      name: outfitName,
      imageUrl: outfitImageUrl,
      productIds: productIds,
    );

    final outfitsCollection = FirebaseFirestore.instance.collection('favorite_outfits');

    outfitsCollection
        .doc(_user.uid)
        .collection('items')
        .add({
      'name': outfit.name,
      'imageUrl': outfit.imageUrl,
      'productIds': outfit.productIds,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Outfit added to favorites.'),
      ),
    );
  }
}

class OutfitModel {
  final String id;
  String name;
  String imageUrl;
  final List<String> productIds;

  OutfitModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productIds,
  });
}
