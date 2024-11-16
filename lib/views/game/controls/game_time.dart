import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart'; // Import for Color
import 'package:pixel_adventure/views/game/pixel_adventure.dart';

class GameTime extends TextComponent with HasGameRef<PixelAdventure> {
  double _elapsedTime = 0; // Biến lưu thời gian đã trôi qua

  GameTime() : super(text: 'Time: 0');

  @override
  FutureOr<void> onLoad() async {
    position = Vector2(
      560, 
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

    // Tăng thời gian dựa trên thời gian cập nhật (delta time)
    _elapsedTime += dt;

    // Cập nhật text để hiển thị thời gian đã trôi qua, làm tròn 2 chữ số thập phân
    text = 'Time: ${_elapsedTime.toStringAsFixed(2)}';
  }

  // Hàm để reset thời gian nếu cần
  void resetTime() {
    _elapsedTime = 0;
  }

  // Hàm lấy thời gian đã trôi qua
  double get elapsedTime => _elapsedTime;
}
