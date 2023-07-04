import 'package:flutter/material.dart';
import 'package:mybarter/views/screens/bartertabscreen.dart';
import 'package:mybarter/views/screens/profiletabscreen.dart';
import 'package:mybarter/views/screens/ownertabscreen.dart';

import '../../models/user.dart';



//for buyer screen

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> tabchildren;
  int _currentIndex = 0;
  String maintitle = "Barter";

  @override
  void initState() {
    super.initState();
    print(widget.user.name);
    print("Mainscreen");
    tabchildren = [
      BarterTabScreen(user: widget.user),
      OwnerTabScreen(user: widget.user),
      ProfileTabScreen(user: widget.user),
   
    ];
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: tabchildren[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.shopping_bag,
                  color: Colors.amber,
                ),
                label: "Barter"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.amber,
                ),
                label: "Owner"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: Colors.amber,
                ),
                label: "Profile"),
            
          ],
               selectedItemColor: Colors.amber[700],
           selectedLabelStyle: TextStyle(color: Colors.amber[700],)
          ),
    );
  }

  void onTabTapped(int value) {
    setState(() {
      _currentIndex = value;
      if (_currentIndex == 0) {
        maintitle = "Barter";
      }
      if (_currentIndex == 1) {
        maintitle = "Owner";
      }
      if (_currentIndex == 2) {
        maintitle = "Profile";
      }
    
    });
  }
}