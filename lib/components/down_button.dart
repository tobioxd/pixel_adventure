import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class DownButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  DownButton();

  final margin = 32;
  final buttonSize = 32;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/DownButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize - 220,
      game.size.y - margin - buttonSize - 60,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.isFastFalling = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.isFastFalling = false;
    super.onTapUp(event);
  }
}