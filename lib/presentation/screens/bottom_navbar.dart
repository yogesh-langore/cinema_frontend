import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_cinema/presentation/screens/create_movie_screen.dart';
import 'package:flutter_cinema/presentation/screens/fav_movie_screen.dart';
import 'package:flutter_cinema/presentation/screens/feedback_screen.dart';
import 'package:flutter_cinema/presentation/screens/home_screen.dart';
import 'package:flutter_cinema/presentation/screens/search_screen.dart';


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
    FavScreen(),
    FeedbackScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F1116),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          screens[selectedIndex],

          // Custom Bottom NavBar
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, left: 25.0, right: 25.0), // Apply horizontal padding here
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  // Remove the horizontal margin from here as it's now in the Padding
                  // margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildNavIcon(Icons.home, 0),
                          const SizedBox(width: 30),
                          _buildNavIcon(Icons.search, 1),
                        ],
                      ),
                      Row(
                        children: [
                          _buildNavIcon(Icons.favorite, 2),
                          const SizedBox(width: 30),
                          _buildNavIcon(Icons.comment, 3),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center Floating Add Button
          Positioned(
            bottom: 60,
            child: Container(
              height: 65,
              width: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 35),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMovieScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom NavBar Icon Builder
  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Icon(
        icon,
        color: isSelected ? Colors.lightBlueAccent : Colors.white,
        size: 28,
      ),
    );
  }
}