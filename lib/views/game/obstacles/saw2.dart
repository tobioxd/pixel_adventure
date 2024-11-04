import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/views/game/pixel_adventure.dart';

class Saw2 extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final double offNeg;
  final double offPos;
  final double verticalOffset; 
  Saw2({
    this.offNeg = 0,
    this.offPos = 0,
    this.verticalOffset = 2, 
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  static const double sawSpeed = 0.03;
  static const moveSpeed = 50;
  static const tileSize = 16;
  int movePhase = 0; // 0: right, 1: down, 2: left, 3: up
  double rangeLeft = 0;
  double rangeRight = 0;
  double rangeTop = 0;
  double rangeBottom = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    rangeLeft = position.x - offNeg * tileSize;
    rangeRight = position.x + offPos * tileSize;
    rangeTop = position.y;
    rangeBottom = position.y + verticalOffset * 1.5 * tileSize;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Saw/On (38x38).png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: sawSpeed,
          textureSize: Vector2.all(38),
        ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _moveRectangular(dt);
    super.update(dt);
  }

  void _moveRectangular(double dt) {
    switch (movePhase) {
      case 0: // Move right
        position.x += moveSpeed * dt;
        if (position.x >= rangeRight) {
          position.x = rangeRight;
          movePhase = 1;
        }
        break;
      case 1: // Move down
        position.y += moveSpeed * dt;
        if (position.y >= rangeBottom) {
          position.y = rangeBottom;
          movePhase = 2;
        }
        break;
      case 2: // Move left
        position.x -= moveSpeed * dt;
        if (position.x <= rangeLeft) {
          position.x = rangeLeft;
          movePhase = 3;
        }
        break;
      case 3: // Move up
        position.y -= moveSpeed * dt;
        if (position.y <= rangeTop) {
          position.y = rangeTop;
          movePhase = 0;
        }
        break;
    }
  }
}
