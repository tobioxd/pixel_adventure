// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/down_button.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showControls = false;
  bool playSounds = true;
  double soundVolume = 0.75;
  List<String> levelNames = [
    'Level-01',
    'Level-01',
    'Level-01',
  ];
  int currentLevel = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    _loadLevel();

    return super.onLoad();
  }

  @override
  void update(dt) {
    if (showControls) {
      updateJoyStick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 1,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 35),
    );

    cam.viewport.add(joystick);
  }

  void updateJoyStick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere(
        (component) => component is Level || component is CameraComponent);

    if (currentLevel < levelNames.length - 1) {
      currentLevel++;
    } else {
      // no more levels
      currentLevel = 0;
    }

    _loadLevel();
  }

  void _loadLevel() {
    try {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevel],
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);

      if (showControls) {
      addJoystick();
      // add(JumpButton());
      cam.viewport.add(JumpButton());
      cam.viewport.add(DownButton());
    }
    
    } catch (e) {
      print('Error loading level: $e');
    }
  }

  static int totalFruitCount(PixelAdventure game) {
    final fruits = game.world.children.whereType<Fruit>();
    return fruits.length;
  }

}
