import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw3 extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final double offNeg;
  final double offPos;
  final double verticalOffset;
  Saw3({
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
  double moveDirection = 1;
  double rangeLeft = 0;
  double rangeRight = 0;
  double rangeTop = 0;
  double rangeBottom = 0;
  int currentPhase = 0; // 0: left, 1: up, 2: right, 3: down

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    rangeLeft = position.x - offNeg * tileSize;
    rangeRight = position.x + offPos * tileSize;
    rangeTop = position.y - verticalOffset * 1.5 * tileSize;
    rangeBottom = position.y;

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
    switch (currentPhase) {
      case 0: // Moving left
        position.x -= moveSpeed * dt;
        if (position.x <= rangeLeft) {
          position.x = rangeLeft;
          currentPhase = 1;
        }
        break;
      case 1: // Moving up
        position.y -= moveSpeed * dt;
        if (position.y <= rangeTop) {
          position.y = rangeTop;
          currentPhase = 2;
        }
        break;
      case 2: // Moving right
        position.x += moveSpeed * dt;
        if (position.x >= rangeRight) {
          position.x = rangeRight;
          currentPhase = 3;
        }
        break;
      case 3: // Moving down
        position.y += moveSpeed * dt;
        if (position.y >= rangeBottom) {
          position.y = rangeBottom;
          currentPhase = 0;
        }
        break;
    }
  }
}