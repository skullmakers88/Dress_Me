import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/models/productsModel.dart';
import 'package:eco_buy/utils/styles.dart';
import 'package:eco_buy/widgets/eco_button.dart';
import 'package:eco_buy/widgets/ecotextfield.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

import '../../../models/categoryModel.dart';

class AddProductScreen extends StatefulWidget {
  static const String id = "addproduct";

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController idC = TextEditingController();
  TextEditingController productNameC = TextEditingController();

  bool isOnSale = false;
  bool isPopular = false;
  bool isFavourite = false;

  Set<String> selectedValues = {};
  bool isSaving = false;
  bool isUploading = false;

  final imagePicker = ImagePicker();
  List<XFile> images = [];
  List<String> imageUrls = [];
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Column(
              children: [
                const Text(
                  "ADD PRODUCT",
                  style: EcoStyle.boldStyle,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: categories
                        .map((e) => FilterChip(
                      label: Text(e.title!),
                      selected: selectedValues.contains(e.title),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedValues.add(e.title!);
                          } else {
                            selectedValues.remove(e.title!);
                          }
                        });
                      },
                    ))
                        .toList(),
                  ),
                ),
                EcoTextField(
                  controller: productNameC,
                  hintText: "enter product name...",
                  validate: (v) {
                    if (v!.isEmpty) {
                      return "should not be empty";
                    }
                    return null;
                  },
                ),
                EcoButton(
                  title: "PICK IMAGES",
                  onPress: () {
                    pickImage();
                  },
                  isLoginButton: true,
                ),
                Container(
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                    ),
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Image.file(
                                  File(images[index].path),
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                )
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    images.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.cancel_outlined))
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SwitchListTile(
                    title: const Text("Is this Product on Sale?"),
                    value: isOnSale,
                    onChanged: (v) {
                      setState(() {
                        isOnSale = !isOnSale;
                      });
                    }),
                SwitchListTile(
                    title: const Text("Is this Product Popular?"),
                    value: isPopular,
                    onChanged: (v) {
                      setState(() {
                        isPopular = !isPopular;
                      });
                    }),
                EcoButton(
                  title: "SAVE",
                  isLoginButton: true,
                  onPress: () {
                    save();
                  },
                  isLoading: isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  save() async {
    setState(() {
      isSaving = true;
    });

    // Obtain the currently authenticated user's ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await uploadImages();

      final List<String> selectedCategories = selectedValues.toList();

      await Products.addProducts(Products(
        uploaderId: userId, // Assign the user's ID to the product
        categories: selectedCategories,
        id: uuid.v4(),
        productName: productNameC.text,
        imageUrls: imageUrls,
        isSale: isOnSale,
        isPopular: isPopular,
        isFavourite: isFavourite,
      )).whenComplete(() {
        setState(() {
          isSaving = false;
          imageUrls.clear();
          images.clear();
          clearFields();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("ADDED SUCCESSFULLY")));
        });
      });
    } else {
      // Handle the case where the user is not authenticated
      print("User is not authenticated");
    }
  }

  clearFields() {
    setState(() {
      productNameC.clear();
    });
  }

  pickImage() async {
    final List<XFile>? pickImage = await imagePicker.pickMultiImage();
    if (pickImage != null) {
      setState(() {
        images.addAll(pickImage);
      });
    } else {
      print("no images selected");
    }
  }

  Future<String?> postImages(XFile? imageFile) async {
    setState(() {
      isUploading = true;
    });

    String? downloadUrl;

    Reference ref = FirebaseStorage.instance.ref().child("images").child(imageFile!.name);

    await ref.putData(
      await imageFile.readAsBytes(),
      SettableMetadata(contentType: "image/jpeg"),
    );
    downloadUrl = await ref.getDownloadURL();

    setState(() {
      isUploading = false;
    });

    return downloadUrl;
  }

  uploadImages() async {
    for (var image in images) {
      await postImages(image).then((downLoadUrl) => imageUrls.add(downLoadUrl!));
    }
  }
}
