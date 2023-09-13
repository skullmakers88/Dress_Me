import 'package:eco_buy/screens/landing_screen.dart';
import 'package:eco_buy/screens/layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'auth_screens/login_screen.dart';
import 'bottom_screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading for 3 seconds (you can replace this with your actual loading logic)
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to HomeScreen after loading is done
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LandingScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Dress Up",
              style: TextStyle(
                fontSize: 30.sp, // Adjust the font size as needed
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // Add spacing between text and loading indicator
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
