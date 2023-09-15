import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/models/categoryModel.dart';
import 'package:eco_buy/models/productsModel.dart';
import 'package:eco_buy/utils/styles.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/category_home_boxex.dart';
import '../../widgets/home_cards.dart';
import '../product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List images = [
    "https://cdn.pixabay.com/photo/2015/09/21/14/24/supermarket-949913_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/11/22/19/08/hangers-1850082_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/07/24/21/01/thermometer-1539191_960_720.jpg",
    "https://cdn.pixabay.com/photo/2015/09/21/14/24/supermarket-949913_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/11/22/19/08/hangers-1850082_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/07/24/21/01/thermometer-1539191_960_720.jpg",
  ];

  List<Products> allProducts = [];

  getDate() async {
    await FirebaseFirestore.instance
        .collection("products")
        .get()
        .then((QuerySnapshot? snapshot) {
      snapshot!.docs.forEach((e) {
        if (e.exists) {
          final dynamic categoryData = e["category"];
          final List<String> categories = categoryData is List<dynamic>
              ? List<String>.from(categoryData)
              : <String>[categoryData as String];

          setState(() {
            allProducts.add(
              Products(
                brand: e["brand"],
                categories: e["category"],
                id: e['id'],
                productName: e["productName"],
                detail: e["detail"],
                price: e["price"],
                discountPrice: e["discountPrice"],
                serialCode: e["serialCode"],
                imageUrls: e["imageUrls"],
                isSale: e["isOnSale"],
                isPopular: e["isPopular"],
                isFavourite: e["isFavourite"],
              ),
            );
          });
        }
      });
    });
    print(allProducts[0].discountPrice);
  }


  Future<void> _refreshData() async {
    setState(() {
      allProducts.clear();
    });
    await getDate();
  }

  @override
  void initState() {
    getDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Dress ",
                      style: TextStyle(
                        fontSize: 27,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "up",
                      style: TextStyle(
                        fontSize: 27,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // const CategoryHomeBoxes(),
              Container(
                // height: .h,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(
                      //   "Trending Outfits",
                      //   style: TextStyle(
                      //     fontSize: 25,
                      //   ),
                      // ),
                      // SizedBox(width: 10), // Add spacing between text and image
                      // Image.asset(
                      //   'assets/c_images/fire.png',
                      //   width: 40, // Adjust the width as needed
                      //   height: 40, // Adjust the height as needed
                      // ),
                      Carousel(
                        images: images,
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
                          children: [
                            Text(
                              "Trending Outfits",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            SizedBox(width: 10), // Add spacing between text and image
                            Image.asset(
                              'assets/c_images/fire.png',
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                            ),
                          ],
                        ),
                      ),
                      allProducts.isEmpty
                          ? CircularProgressIndicator()
                          : TrendingOutfits(allProducts: allProducts),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrendingOutfits extends StatelessWidget {
  const TrendingOutfits({
    Key? key,
    required this.allProducts,
  }) : super(key: key);

  final List<Products> allProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63.h, // Adjust the height as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: allProducts
              .where((element) => element.isPopular == true)
              .map((product) {
            return InkWell(
              onTap: () {
                // Navigate to the product details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      id: product.id, // Pass the product ID
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Black border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(10), // Optional: Add rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: product.imageUrls!
                            .map((imageUrl) => Container(
                          width: 150, // Adjust the image width as needed
                          height: 150, // Adjust the image height as needed
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 150, // Adjust the image width as needed
                            height: 150, // Adjust the image height as needed
                            fit: BoxFit.cover, // Ensure images fit within the container
                          ),
                        ))
                            .toList(),
                      ),
                      SizedBox(
                        height: 10, // Add spacing between images and name
                      ),
                      Text(
                        product.productName!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}



class Carousel extends StatelessWidget {
  const Carousel({
    Key? key,
    required this.images,
  }) : super(key: key);

  final List images;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: images
          .map((e) => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                imageUrl: e,
                placeholder: (c, i) =>
                    Center(child: Image.asset(categories[0].image!)),
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.3),
                    Colors.redAccent.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "TITLE",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ))
          .toList(),
      options: CarouselOptions(
        height: 140,
        autoPlay: true,
      ),
    );
  }
}
