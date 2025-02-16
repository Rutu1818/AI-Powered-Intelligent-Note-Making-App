import 'package:flutter/material.dart';
import 'package:practice/screens/home_screen.dart';
import 'package:practice/screens/upload_screen.dart';  // Updated import
import '../screens/profile.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    UploadScreen(),  // Updated class reference
    const HomeScreen(),
    Profile(),
  ];

  int i = 0;

  void _ontappeditem(int index) {
    setState(() {
      i = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: _ontappeditem,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded), label: "add"),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded), label: "account")
        ],
      ),
    );
  }
}
