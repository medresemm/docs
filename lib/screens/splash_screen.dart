import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020817),
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/nibras_plans_splash.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}