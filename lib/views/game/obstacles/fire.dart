import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/views/game/pixel_adventure.dart';
import 'package:pixel_adventure/views/game/players/player.dart';

class Fire extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  bool activated = false;
  final double stepTime = 0.1;

  Fire({
    required Vector2 position,
  }) : super(position: position, size: Vector2(16, 32));

  @override
  FutureOr<void> onLoad() async {
    add(
      RectangleHitbox(
        size: size,
        position: Vector2.zero(),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/On (16x32).png'),
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: stepTime,
        textureSize: Vector2(16, 32),
      ),
    );
    return super.onLoad();
  }

  void collidedWithPlayer(Player player) async {
    if (!activated) {
      activated = true;

      if (game.playSounds) {
        FlameAudio.play('hit.wav', volume: game.soundVolume);
      }

      player.gotHit = true;

      // Optionally, you can add an animation or effect when the fire is activated
      // For example, you can change the animation to a "burned" state
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Fire/Off.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
          loop: false,
        ),
      );

      await animationTicker?.completed;
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Fire/On (16x32).png'),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
        ),
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      collidedWithPlayer(other);
    }
  }
}
