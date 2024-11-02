import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String buttonText;
  final void Function() onTap;

  const AppButton({
    super.key,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF211F30),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
