import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/widgets/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Create a class to represent an outfit
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

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<String> ids = [];

  Future<void> _getId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorite_outfits')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('items')
        .get();

    setState(() {
      ids = snapshot.docs.map((doc) => doc.id).toList();
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
                stream: FirebaseFirestore.instance.collection('favorite_outfits')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('items')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final favoriteOutfits = snapshot.data!.docs
                      .map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return OutfitModel(
                      id: doc.id,
                      name: data['name'] ?? '', // Name is optional, set to empty string if null
                      imageUrl: data['imageUrl'] ?? '', // Image URL is optional, set to empty string if null
                      productIds: List<String>.from(data['productIds'] ?? []),
                    );
                  })
                      .toList();

                  if (favoriteOutfits.isEmpty) {
                    return Center(child: Text("No Favorite Outfits Found"));
                  }

                  return  ListView.builder(
                    itemCount: favoriteOutfits.length,
                    itemBuilder: (BuildContext context, int index) {
                      final outfit = favoriteOutfits[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.7.h),
                        child: InkWell(
                          onTap: () {
                            // Implement navigation to view outfit details or edit it
                            // You can navigate to a new screen with outfit details here
                          },
                          child: Card(
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Custom leading widget (Image)
                                  Image.network(
                                    outfit.imageUrl,
                                    width: 50.0,
                                    height: 50.0,
                                  ),
                                  SizedBox(width: 10.0), // Adjust spacing as needed
                                  // Custom title widget (Text)
                                  Expanded(
                                    child: Text(
                                      outfit.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Custom trailing widget (IconButton)
                                  IconButton(
                                    onPressed: () {
                                      // Implement actions for the outfit (e.g., view, edit, delete)
                                    },
                                    icon: Icon(
                                      Icons.navigate_next_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
