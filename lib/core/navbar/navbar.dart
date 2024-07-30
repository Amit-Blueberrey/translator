
import 'package:flutter/material.dart';
import 'package:translator/core/utils/color.dart';
import 'package:translator/features/camera_translation/view/camera_text_Recognition.dart';
import 'package:translator/features/one_on_one_translation/one_on_one.dart';
import 'package:translator/features/translation/views/translation.dart';

class navBar extends StatefulWidget {
  const navBar({Key? key}) ;

  @override
  State<navBar> createState() => _NavBarState();
}

class _NavBarState extends State<navBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    translation_home(),
    camera_recognition(),
    OneOnOneCommunicationPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor, // Colors.grey[800]
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,  // Change the color to your desired color
        unselectedItemColor: const Color.fromARGB(255, 57, 57, 57),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_enhance_outlined),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_outlined),
            label: 'One-on-One',
          ),
        ],
      ),
    );
  }
}