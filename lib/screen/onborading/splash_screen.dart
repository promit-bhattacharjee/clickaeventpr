import 'dart:async';
import 'package:clickaeventpr/screen/onborading/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'splash_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../main manu/home.dart';
import '../widgets/bodyBackground.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  changeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()));
      // auth.authStateChanges().listen((User? user) {
      //   if (user == null && mounted) {
      //     Get.to(() => const WelcomeScreen());
      //   } else {
      //     Get.to(() => const Home());
      //   }
      // });
    });
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return BodyBackground(
      child: Stack(
        children: [
          SvgPicture.asset('assets/images/balloonebackground.svg',
              fit: BoxFit.cover,
              width: screenSize.width,
              height: screenSize.height),
          // SvgPicture.asset
          Center(
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: 350,
              fit: BoxFit.scaleDown,
            ),
          )
        ],
      ),
    );
  }
} // Column
