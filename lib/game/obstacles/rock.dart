import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/game/players/player.dart';
import 'package:pixel_adventure/game/screens/pixel_adventure.dart';

class Rock extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final bool isVertical;
  final double offNeg;
  final double offPos;
  Rock({
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
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
  double rangeNeg = 0;
  double rangePos = 0;
  late final Player player;
  bool isPlayerRiding = false;

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    priority = -1;
    add(RectangleHitbox());

    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Rock Head/Idle.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: sawSpeed,
          textureSize: Vector2.all(42),
        ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Lưu vị trí cũ trước khi di chuyển
    double oldY = position.y;
    
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    // Nếu player đang đứng trên rock, di chuyển player theo
    if (isPlayerRiding && isPlayerOnTop()) {
      double deltaY = position.y - oldY;
      player.position.y += deltaY;
      player.velocity.y = 0;
      player.isOnGround = true;
      print(oldY);
    print('Rock position: $position');
    print('Player position: ${player.position}');
    }

    // Kiểm tra xem player còn đứng trên rock không
    if (isPlayerRiding) {
      if (!isPlayerOnTop()) {
        isPlayerRiding = false;
      }
    }

    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  bool isPlayerOnTop() {
  final playerBox = player.position + Vector2(player.hitbox.offsetX, player.hitbox.offsetY);
  final rockBox = position;

  // Define the top surface of the rock
  final rockTopY = rockBox.y; // The Y position of the rock
  final rockBottomY = rockTopY + 5; // Adjust according to the height of the rock

  // Check if the player is on top of the rock
  bool isOnTop = playerBox.y + player.hitbox.height <= rockBottomY &&
      playerBox.y + player.hitbox.height >= rockTopY &&
      playerBox.x + player.hitbox.width > rockBox.x &&
      playerBox.x < rockBox.x + size.x;

  return isOnTop;
}


  void collidedWithPlayer() {
    if (isPlayerOnTop()) {
      isPlayerRiding = true;
      player.isOnGround = true;
      player.velocity.y = 0;
      // Đặt player đứng chính xác trên đỉnh của rock
      player.position.y = position.y - player.hitbox.height - player.hitbox.offsetY;
    } else {
      // Nếu va chạm từ bên cạnh, đẩy player ra
    
    }
  }
}