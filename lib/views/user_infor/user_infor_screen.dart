import 'package:flutter/material.dart';

class UserInforScreen extends StatelessWidget {
  const UserInforScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
