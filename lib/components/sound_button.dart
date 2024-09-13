import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class SoundButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  SoundButton();

  final margin = 32;
  final buttonSize = 32;

  @override
  FutureOr<void> onLoad() {
    updateSprite();
    position = Vector2(
        margin - 12 , 
        margin - 12 ,
        );
    priority = 10;
    return super.onLoad();
  }

  void updateSprite() {
    sprite = Sprite(game.images.fromCache(
        game.playSoundsBackground ? 'HUD/unmute.png' : 'HUD/mute.png'));
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.toggleBackgroundMusic();
    updateSprite();
    super.onTapDown(event);
  }
}
