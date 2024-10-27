import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/game/components/collision_block.dart';
import 'package:pixel_adventure/game/players/player.dart';
import 'package:pixel_adventure/game/screens/pixel_adventure.dart';

enum RhinoState { idle, run, hit, hitwall }

class Rhino extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg;
  final double offPos;

  Rhino({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const stepTime = 0.1;
  static const tileSize = 16;
  static const runSpeed = 260;
  static const _bounceHeight = 280.0;
  final textureSize = Vector2(52, 34);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;
  bool isHittingWall = false;
  bool isActive = false;
  bool isMovingRight = false;

  late final Player player;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _hitWallAnimation;

  @override
  FutureOr<void> onLoad() {
    player = game.player;

    add(
      RectangleHitbox(
        position: Vector2(8, 10),
        size: Vector2(36, 24),
      ),
    );
    _loadAllAnimations();
    _calculateRange();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 11);
    _runAnimation = _spriteAnimation('Run', 6);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;
    _hitWallAnimation = _spriteAnimation('Hit Wall', 4)..loop = false;

    animations = {
      RhinoState.idle: _idleAnimation,
      RhinoState.run: _runAnimation,
      RhinoState.hit: _hitAnimation,
      RhinoState.hitwall: _hitWallAnimation,
    };

    current = RhinoState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Rino/$state (52x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      if (!isActive) {
        isActive = playerInRange();
      }
      _updateState();
      _movement(dt);
      _checkEndpoints(); // Thay thế _checkHorizontalCollisions bằng _checkEndpoints
    }
    super.update(dt);
  }

  void _checkEndpoints() {
    if (position.x <= rangeNeg) {
      position.x = rangeNeg;
      _hitEndpoint();
    } else if (position.x >= rangePos - width) {
      position.x = rangePos - width;
      _hitEndpoint();
    }
  }

  // void _hitEndpoint() async {
  //   if (!isHittingWall) {
  //     isHittingWall = true;
  //     current = RhinoState.hitwall;
  //     velocity.x = 0; // Stop moving initially

  //     // Delay before moving backward
  //     await Future.delayed(const Duration(milliseconds: 500));

  //     // Move backward without changing direction
  //     position.x -= 20 * targetDirection; // Adjust the distance as needed

  //     // Delay before moving backward
  //     await Future.delayed(const Duration(milliseconds: 500));

  //     targetDirection *= -1; // Đổi hướng
  //     isMovingRight = !isMovingRight;

  //     // After moving backward, reset hitting wall status
  //     isHittingWall = false;
  //   }
  // }

  void _hitEndpoint() async {
    if (!isHittingWall) {
      isHittingWall = true;
      current = RhinoState.hitwall;
      velocity.x = 0; // Dừng di chuyển ban đầu

      // Rhino nảy lên một chút
      position.y -= 20; // Điều chỉnh khoảng cách nảy lên
      await Future.delayed(
          const Duration(milliseconds: 200)); // Đợi một chút khi nảy lên

      // Sau đó, Rhino rơi xuống lại vị trí cũ
      position.y += 20;
      await Future.delayed(
          const Duration(milliseconds: 200)); // Đợi một chút khi rơi xuống

      // Di chuyển lùi lại mà không thay đổi hướng
      position.x -= 20 * targetDirection; // Điều chỉnh khoảng cách bật lùi

      // Chờ một chút trước khi đổi hướng
      await Future.delayed(const Duration(milliseconds: 500));

      targetDirection *= -1; // Đổi hướng
      isMovingRight = !isMovingRight;

      // Sau khi di chuyển lùi, reset trạng thái đụng tường
      isHittingWall = false;
    }
  }

  void _movement(double dt) {
    if (!isHittingWall) {
      velocity.x = 0;

      if (isActive) {
        velocity.x = targetDirection * runSpeed;
      }

      moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
      position.x += velocity.x * dt;
    }
  }

  void _calculateRange() {
    // Điều chỉnh khoảng cách di chuyển
    rangeNeg = position.x - offNeg * tileSize * 0.75;
    rangePos = position.x + offPos * tileSize * 2.5;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    if (!isHittingWall) {
      current = (velocity.x != 0) ? RhinoState.run : RhinoState.idle;
    }

    // Cập nhật hướng nhìn của Rhino
    if ((velocity.x > 0 && scale.x > 0) || (velocity.x < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotStomped = true;
      current = RhinoState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedwithEnemy();
    }
  }
}
