
import 'package:eco_buy/screens/SplachScreen.dart';
import 'package:eco_buy/screens/bottom_page.dart';
import 'package:eco_buy/screens/bottom_screens/web_side/addProducts_screen.dart';
import 'package:eco_buy/screens/bottom_screens/web_side/updateProduct_screen.dart';
import 'package:eco_buy/screens/bottom_screens/web_side/web_login.dart';
import 'package:eco_buy/screens/bottom_screens/web_side/web_main.dart';
import 'package:eco_buy/screens/landing_screen.dart';
import 'package:eco_buy/screens/layout_screen.dart';
import 'package:eco_buy/screens/auth_screens/login_screen.dart';
// import 'package:eco_buy/screens/web_side/update_complete_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAjJHYe4ANI1IvShKS8t0b3mKO2mAOloA0",
            authDomain: "fashion-app-2b5a7.firebaseapp.com",
            projectId: "fashion-app-2b5a7",
            storageBucket: "fashion-app-2b5a7.appspot.com",
            messagingSenderId: "744094423917",
            appId: "1:744094423917:web:9810dfc949d39931039864",
            measurementId: "G-8JK1QC84QY"));
  } else {

  await Firebase.initializeApp();

  }
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'ECO BUY',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: SplashScreen(),
        routes: {
          WebLoginScreen.id: (context) => WebLoginScreen(),
          WebMainScreen.id: (context) => WebMainScreen(),
          AddProductScreen.id: (context) => AddProductScreen(),
          UpdateProductScreen.id: (context) => UpdateProductScreen(),
        },
      ),
    );
  }
}
