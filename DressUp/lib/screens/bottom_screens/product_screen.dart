import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';

import '../../models/categoryModel.dart';
import '../../models/productsModel.dart';

class ProductScreen extends StatefulWidget {
  String? category;
  ProductScreen({this.category});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Products> allProducts = [];
  List<Products> totalItems = [];
  TextEditingController sC = TextEditingController();
  bool isLoading = true;
  Set<String> selectedCategories = Set(); // Use a set to track selected categories

  @override
  void initState() {
    super.initState();
    getDate();
  }

  getDate() async {
    await Future.delayed(Duration(seconds: 2));
    await FirebaseFirestore.instance
        .collection("products")
        .get()
        .then((QuerySnapshot? snapshot) {
      if (snapshot != null) {
        setState(() {
          // Clear the totalItems list before updating it
          totalItems.clear();
          allProducts = snapshot.docs.map((e) {
            return Products(
              id: e["id"],
              productName: e["productName"],
              imageUrls: e["imageUrls"],
              categories: e["category"]?.cast<String>(),
            );
          }).toList();
          isLoading = false;
          totalItems.addAll(allProducts); // Store all products in totalItems
        });
      }
    });
  }


  filterData(String query) {
    setState(() {
      if (query.isNotEmpty || selectedCategories.isNotEmpty) {
        List<Products> filteredProducts = totalItems.where((product) {
          final productNameMatches = product.productName!
              .toLowerCase()
              .contains(query.toLowerCase());

          final categoryMatches = selectedCategories.isEmpty ||
              selectedCategories.contains("All") ||
              (product.categories != null &&
                  product.categories!.any((category) =>
                      selectedCategories.contains(category)));

          return productNameMatches && categoryMatches;
        }).toList();
        allProducts = filteredProducts;
      } else {
        // Reset to all products when both query and selectedCategories are empty
        allProducts.clear();
        allProducts.addAll(totalItems);
      }
    });
  }


  List<Products> get filteredProducts {
    if (selectedCategories.isEmpty) {
      return allProducts;
    }
    return allProducts
        .where((product) =>
    product.categories != null &&
        product.categories!.any((category) =>
            selectedCategories.contains(category)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20.0), // Increase the top padding as needed
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: sC,
                    onChanged: (v) {
                      filterData(sC.text);
                    },
                    decoration: InputDecoration(
                      hintText: "Search your favorite product...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showCategoryMenu();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // Background color
                  onPrimary: Colors.black, // Text color
                  side: BorderSide(width: 2, color: Colors.black), // Border width and color
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0), // Adjust the padding as needed
                  child: Text(
                    "Dress Me",
                    style: TextStyle(fontSize: 20), // Adjust the font size as needed
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await getDate();
                  },
                  child: Builder(
                    builder: (context) {
                      return ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    id: filteredProducts[index].id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Row(
                                      children: filteredProducts[index].imageUrls!
                                          .map((imageUrl) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Image.network(
                                            imageUrl,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ))
                                          .toList(),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    filteredProducts[index].productName!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void showCategoryMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Select Categories"),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: Text("All"),
                      value: selectedCategories.isEmpty,
                      onChanged: (bool value) {
                        setState(() {
                          if (value) {
                            selectedCategories.clear();
                          } else {
                            selectedCategories.addAll(categories
                                .map((category) => category.title ?? ""));
                          }
                        });
                      },
                    ),
                    for (Category category in categories)
                      SwitchListTile(
                        title: Text(category.title ?? ""),
                        value: selectedCategories.contains(category.title),
                        onChanged: (bool value) {
                          setState(() {
                            if (value) {
                              selectedCategories.add(category.title ?? "");
                            } else {
                              selectedCategories.remove(category.title);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
