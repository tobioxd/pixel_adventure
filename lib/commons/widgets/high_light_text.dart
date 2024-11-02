import 'package:flutter/material.dart';

class HighLightText extends StatelessWidget {
  final String text;
  final double fontSize;

  const HighLightText({
    super.key,
    required this.text,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.white,
            offset: Offset(0, 0),
          ),
        ],
      ),
    );
  }
}
