import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/views/game/pixel_adventure.dart';
import 'package:pixel_adventure/views/game/states/globalstate.dart';

class Life extends PositionComponent with HasGameRef<PixelAdventure> {
  Life();

  final toX = 50;
  final toY = 32;
  final heartSize = 10.67; 

  @override
  FutureOr<void> onLoad() async {
    await _loadHearts();
    return super.onLoad();
  }

  Future<void> _loadHearts() async {
    
    removeAll(children);

    for (int i = 0; i < GlobalState().life; i++) {
      final heartSprite = SpriteComponent()
        ..sprite = await gameRef.loadSprite('HUD/Heart.png')
        ..size = Vector2(heartSize, heartSize)
        ..position = Vector2((toX + i * (heartSize + 1)), toY.toDouble()); 

      add(heartSprite);
    }
  }

  void updateHearts() async {
    print(GlobalState().life);
    await _loadHearts(); 
  }
}