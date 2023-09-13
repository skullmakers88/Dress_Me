import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/models/productsModel.dart';
import 'package:eco_buy/utils/styles.dart';
import 'package:eco_buy/widgets/eco_button.dart';
import 'package:eco_buy/widgets/ecotextfield.dart';
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
  // TextEditingController detailC = TextEditingController();
  // TextEditingController priceC = TextEditingController();
  // TextEditingController discountPriceC = TextEditingController();
  // TextEditingController serialCodeC = TextEditingController();
  // TextEditingController brandC = TextEditingController();

  bool isOnSale = false;
  bool isPopular = false;
  bool isFavourite = false;

  Set<String> selectedValues = {}; // Store multiple selected categories.
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
                    spacing: 5, // Adjust spacing as needed.
                    runSpacing: 5, // Adjust spacing as needed.
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
                // ... (other text fields)
                EcoButton(
                  title: "PICK IMAGES",
                  onPress: () {
                    pickImage();
                  },
                  isLoginButton: true,
                ),
                // ... (other widgets)
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
                                  border: Border.all(color: Colors.black)),
                              child: Image.network(
                                File(images[index].path).path,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
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
    await uploadImages();

    final List<String> selectedCategories = selectedValues.toList();

    await Products.addProducts(Products(
      categories: selectedCategories,
      id: uuid.v4(),
      // brand: brandC.text,
      productName: productNameC.text,
      // detail: detailC.text,
      // price: int.parse(priceC.text),
      // discountPrice: int.parse(discountPriceC.text),
      // serialCode: serialCodeC.text,
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

  Future postImages(XFile? imageFile) async {
    setState(() {
      isUploading = true;
    });
    String? urls;
    Reference ref =
    FirebaseStorage.instance.ref().child("images").child(imageFile!.name);
    if (kIsWeb) {
      await ref.putData(
        await imageFile.readAsBytes(),
        SettableMetadata(contentType: "image/jpeg"),
      );
      urls = await ref.getDownloadURL();
      setState(() {
        isUploading = false;
      });
      return urls;
    }
  }

  uploadImages() async {
    for (var image in images) {
      await postImages(image).then((downLoadUrl) => imageUrls.add(downLoadUrl));
    }
  }
}
