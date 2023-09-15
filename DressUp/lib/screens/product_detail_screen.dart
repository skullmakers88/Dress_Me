import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../models/productsModel.dart';
import '../utils/removeFav.dart';
import '../widgets/header.dart';
import '../widgets/eco_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? id;

  const ProductDetailScreen({Key? key, this.id}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Products? currentProduct;
  List<Products> allProducts = [];
  int selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await getAllProducts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllProducts() async {
    final productsSnapshot =
    await FirebaseFirestore.instance.collection("products").get();

    final productId = widget.id ?? "";

    for (var productDoc in productsSnapshot.docs) {
      final productData = productDoc.data();

      final product = Products(
        id: productData['id'] ?? productId,
        productName: productData['productName'] as String?,
        detail: productData['detail'] as String?,
        brand: productData['brand'] as String?,
        imageUrls: productData['imageUrls'] as List<dynamic>?,
        isSale: productData['isSale'] as bool?,
        isPopular: productData['isPopular'] as bool?,
        isFavourite: productData['isFavourite'] as bool?,
        categories: productData['category'] as List<dynamic>?,
      );

      if (product.id != productId) {
        allProducts.add(product);
      } else {
        currentProduct = product;
      }
    }
  }

  addToFavourite() async {
    CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('favourite');
    await collectionReference
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("items")
        .add({"pid": currentProduct!.id});
  }

  @override
  Widget build(BuildContext context) {
    bool isAddedToFavorites = false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: Header(
          title: currentProduct != null ? currentProduct!.productName : "",
        ),
        preferredSize: Size.fromHeight(7.h),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: currentProduct!.imageUrls != null &&
                  currentProduct!.imageUrls!.isNotEmpty
                  ? currentProduct!.imageUrls![selectedIndex] as String
                  : "",
              height: 30.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(
                    currentProduct!.imageUrls != null
                        ? currentProduct!.imageUrls!.length
                        : 0,
                        (index) => InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 12.h,
                          width: 12.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: currentProduct!.imageUrls != null
                                ? currentProduct!.imageUrls![index] as String
                                : "",
                            height: 9.h,
                            width: 9.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('favourite')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('items')
                  .where('pid', isEqualTo: currentProduct!.id)
                  .snapshots(),
              builder:
                  (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Text("");
                }
                isAddedToFavorites = snapshot.data!.docs.isNotEmpty;

                return Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (isAddedToFavorites) {
                          removeFromFavourite(
                              snapshot.data!.docs.first.id)
                              .whenComplete(() {
                            setState(() {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Removed from Favorites successfully"),
                                ),
                              );
                            });
                          });
                        } else {
                          addToFavourite().whenComplete(() {
                            setState(() {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Added to Favorites successfully"),
                                ),
                              );
                            });
                          });
                        }
                      },
                      icon: Icon(
                        Icons.favorite,
                        color: isAddedToFavorites
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    EcoButton(
                      onPress: () {
                        if (isAddedToFavorites) {
                          removeFromFavourite(
                              snapshot.data!.docs.first.id)
                              .whenComplete(() {});
                        } else {
                          addToFavourite().whenComplete(() {});
                        }
                      },
                      title: isAddedToFavorites
                          ? "Remove from Favorites"
                          : "Add to Favorites",
                    ),
                  ],
                );
              },
            ),
            Container(
              constraints: BoxConstraints(
                minWidth: double.infinity,
                minHeight: 30.h,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentProduct!.detail ?? "",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Other Available Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index >= 0 && index < allProducts.length) {
                    final otherProduct = allProducts[index];

                    if (otherProduct.id != widget.id &&
                        (otherProduct.categories == null ||
                            !otherProduct.categories!
                                .any((category) =>
                                currentProduct!.categories!
                                    .contains(category)))) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                id: otherProduct.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: otherProduct.imageUrls != null
                                        ? otherProduct.imageUrls!.last as String
                                        : "",
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    otherProduct.productName ?? "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
