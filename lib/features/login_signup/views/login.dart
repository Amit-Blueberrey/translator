import 'package:flutter/material.dart';
import 'package:translator/core/navigation/navigation_service.dart';

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                NavigationService.goBack();
              },
              child: Text('login'))
          ],
        ),
      ),
    );
  }
}