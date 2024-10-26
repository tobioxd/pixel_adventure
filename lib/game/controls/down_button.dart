import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/game/screens/pixel_adventure.dart';

class DownButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  DownButton();

  final wid = 640;
  final hei = 360;
  final margin = 32;
  final buttonSize = 32;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/DownButton.png'));
    position = Vector2(
      wid - margin - buttonSize - 20,
      hei - margin - buttonSize - 20,
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