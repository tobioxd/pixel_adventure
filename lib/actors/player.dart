import 'dart:async';

import 'package:fixel_adventure/main.dart';
import 'package:flame/components.dart';

enum PlayerState { idle, running }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  final String character;

  Player({super.position, required this.character});

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(amount: 11, state: 'Idle');
    runningAnimation = _spriteAnimation(amount: 11, state: 'Run');
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
      {required int amount, required String state}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: 11,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
