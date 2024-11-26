import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/text.dart'; // Import for TextPaint
import 'package:flutter/material.dart'; // Import for Color
import 'package:pixel_adventure/views/game/pixel_adventure.dart';
import 'package:pixel_adventure/views/game/states/globalstate.dart';

class Pixel extends TextComponent with HasGameRef<PixelAdventure> {
  Pixel() : super(text: 'Blood: 0');

  @override
  FutureOr<void> onLoad() async {
    position = Vector2(
      100, 
      30 
    );

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.red, 
        fontSize: 10, 
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = 'Blood: ${GlobalState().pixel}';
  }
}
