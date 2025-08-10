import 'package:flutter/material.dart';
import 'package:flutter_cinema/presentation/screens/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 2),
      () {
        return Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavBar(),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Text(
              'CINEMA🎞️',
              style: GoogleFonts.orbitron(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Lottie.asset(
                'assets/loading.json',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
