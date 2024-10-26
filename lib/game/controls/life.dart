import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/game/screens/pixel_adventure.dart';
import 'package:pixel_adventure/game/states/globalstate.dart';

class Life extends PositionComponent with HasGameRef<PixelAdventure> {
  Life();

  final toX = 50;
  final toY = 32;
  final heartSize = 10.67; // Reduced to one-third of the original size

  @override
  FutureOr<void> onLoad() async {
    // Clear any existing children (hearts) if needed
    removeAll(children);

    // Load and display hearts based on the life count
    for (int i = 0; i < GlobalState().life; i++) {
      final heartSprite = SpriteComponent()
        ..sprite = await gameRef.loadSprite('HUD/Heart.png')
        ..size = Vector2(heartSize, heartSize)
        ..position = Vector2((toX + i * (heartSize + 1)), toY.toDouble()); // Spacing between hearts

      add(heartSprite);
    }

    return super.onLoad();
  }

  // Call this method to update the hearts whenever life changes
  void updateHearts() async {
    await onLoad(); // Reload the hearts based on the updated life count
  }
}
