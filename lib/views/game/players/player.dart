import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/cores/utils/check_collision.dart';
import 'package:pixel_adventure/cores/utils/custom_hitbox.dart';
import 'package:pixel_adventure/views/game/components/checkpoint.dart';
import 'package:pixel_adventure/views/game/components/collision_block.dart';
import 'package:pixel_adventure/views/game/enemies/chicken.dart';
import 'package:pixel_adventure/views/game/enemies/rhino.dart';
import 'package:pixel_adventure/views/game/items/fruit.dart';
import 'package:pixel_adventure/views/game/obstacles/fire.dart';
import 'package:pixel_adventure/views/game/obstacles/saw.dart';
import 'package:pixel_adventure/views/game/obstacles/saw1.dart';
import 'package:pixel_adventure/views/game/obstacles/saw2.dart';
import 'package:pixel_adventure/views/game/obstacles/saw3.dart';
import 'package:pixel_adventure/views/game/pixel_adventure.dart';
import 'package:pixel_adventure/views/game/states/globalstate.dart';
import 'package:pixel_adventure/views/game_over/game_over_screen.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position);

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  static const double _gravity = 10;
  static const double _jumpForce = 250;
  static const double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool isFastFalling = false;
  bool gotHit = false;
  bool finish = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // const double maxDt = 1 / 60;  // For a max of 60 frames per second
    // dt = dt > maxDt ? maxDt : dt;

    if (!gotHit) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!finish) {
      if (other is Fruit) {
        other.collidedWithPlayer();
      }
      if (other is Saw) _response();
      if (other is Saw1) _response();
      if (other is Saw2) _response();
      if (other is Saw3) _response();
      if (other is Chicken) {
        other.collidedWithPlayer();
      }
      if (other is Rhino) {
        other.collidedWithPlayer();
      }
      if (other is Checkpoint) {
        if (GlobalState().numberFruits == 0) {
          _finish();
          GlobalState().point += 50;
        }
      }
      if (other is Fire) {
        _response();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7);
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Disappearing', 7); //

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // check if Falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // Checks if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
      // Reset horizontal velocity when jumping
      velocity.x = 0;
      horizontalMovement = 0;
    }

    // Apply horizontal movement after jump
    if (velocity.y > _gravity) isOnGround = false;

    // Scale down horizontal speed during jump/fall
    double speedMultiplier = isOnGround ? 1.0 : 0.8; // Reduce air control
    velocity.x = horizontalMovement * moveSpeed * speedMultiplier;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play('jump.wav', volume: game.soundVolume / 2);
    }

    // Apply pure vertical jump force
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (CheckCollision.call(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    double gravity = _gravity;
    if (isFastFalling) {
      gravity *= 11;
    }

    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);

    // Add air resistance when moving horizontally in air
    if (!isOnGround && velocity.x != 0) {
      velocity.x *= 0.98; // Slight air resistance
    }

    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (CheckCollision.call(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (CheckCollision.call(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _response() {
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);

    const hitDuration = Duration(milliseconds: 500);
    const appearingDuration = Duration(milliseconds: 400);
    const canMoveDuration = Duration(milliseconds: 200);
    gotHit = true;
    current = PlayerState.hit;
    Future.delayed(hitDuration, () {
      if (GlobalState().life > 1) {
        GlobalState().minusLife();
        scale.x = 1;
        position = startingPosition - Vector2.all(32);
        current = PlayerState.appearing;
        if (game.playSounds) {
          FlameAudio.play('sponse.wav', volume: game.soundVolume);
        }
        Future.delayed(appearingDuration, () {
          velocity = Vector2.zero();
          position = startingPosition;
          _updatePlayerState();
          Future.delayed(canMoveDuration, () => gotHit = false);
        });
      } else {
        print(GlobalState().getElapsedTime());
        // game.loadFromNew();
        if (game.context.mounted) {
          Navigator.of(game.context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GameOverScreen(
                points: GlobalState().point,
                duration: GlobalState().getElapsedTime(),
                character: GlobalState().playerName,
              ),
            ),
          );
        }
      }
    });
  }

  int areFruitsRemaining() {
    return PixelAdventure.totalFruitCount(game);
  }

  void _finish() {
    finish = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;
    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }

    const reachedCheckpointDuration = Duration(milliseconds: 200);
    Future.delayed(reachedCheckpointDuration, () {
      finish = false;
      position = Vector2.all(-640);

      const waitToChangeDuration = Duration(seconds: 2);
      Future.delayed(waitToChangeDuration, () {
        game.loadNextLevel();
      });
    });
  }

  void collidedwithEnemy() {
    _response();
  }
}
