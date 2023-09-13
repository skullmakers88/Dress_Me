import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_buy/screens/bottom_screens/checkout_screen.dart';
import 'package:eco_buy/screens/bottom_screens/favourite-screen.dart';
import 'package:eco_buy/screens/bottom_screens/home_screen.dart';
import 'package:eco_buy/screens/bottom_screens/product_screen.dart';
import 'package:eco_buy/screens/bottom_screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_switcher/animated_switcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'bottom_screens/web_side/web_main.dart';




class BottomPage extends StatefulWidget {
  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int length = 0;

  void cartItemsLength() {
    FirebaseFirestore.instance.collection('favourite').get().then((snap) {
      if (snap.docs.isNotEmpty) {
        setState(() {
          length = snap.docs.length;
        });
      } else {
        setState(() {
          length = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    cartItemsLength();
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.globe)),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.arrowCircleUp)),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.favorite),
                Positioned(
                  top: 1,
                  right: 1,
                  child: length == 0
                      ? Container()
                      : Stack(
                    children: [
                      Icon(
                        Icons.brightness_1,
                        size: 20,
                        color: Colors.red,
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "$length",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
      tabBuilder: (context, index) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300), // Adjust the duration as needed
          child: CupertinoTabView(
            key: ValueKey<int>(index),
            builder: ((context) {
              switch (index) {
                case 0:
                  return CupertinoPageScaffold(
                    child: HomeScreen(),
                  );
                case 1:
                  return CupertinoPageScaffold(
                    child: ProductScreen(),
                  );
                case 2:
                  return CupertinoPageScaffold(
                    child: WebMainScreen(),
                  );
                case 3:
                  return CupertinoPageScaffold(
                    child: FavouriteScreen(),
                  );
                case 4:
                  return CupertinoPageScaffold(
                    child: ProfileScreen(),
                  );
                default:
                  return CupertinoPageScaffold(
                    child: HomeScreen(),
                  );
              }
            }),
          ),
        );
      },
    );
  }
}
