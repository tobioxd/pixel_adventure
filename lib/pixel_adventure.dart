import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    final world = Level(
      player: player,
      levelName: 'Level-02',
    );

    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    if(showJoystick){
      addJoyStick();
    }

    return super.onLoad();
  }

  @override
  void update(dt){
    if(showJoystick){
      updateJoyStick();
    }
    super.update(dt);
  }
  
  void addJoyStick() {

    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
        size: Vector2.all(50),
        ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
        size: Vector2.all(100),
      ),
      margin: const EdgeInsets.only(left: 10, bottom: 10),
      );
    add(joystick);
  }
  
  void updateJoyStick() {
    switch(joystick.direction){
      case JoystickDirection.up:
        player.playerDirection = PlayerDirection.none;
        break;
      case JoystickDirection.down:
        player.playerDirection = PlayerDirection.none;
        break;
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      case JoystickDirection.idle:
        player.playerDirection = PlayerDirection.none;
        break;
    }
  }
}
