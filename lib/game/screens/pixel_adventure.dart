// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/game/controls/down_button.dart';
import 'package:pixel_adventure/game/controls/life.dart';
import 'package:pixel_adventure/game/items/fruit.dart';
import 'package:pixel_adventure/game/controls/jump_button.dart';
import 'package:pixel_adventure/game/players/player.dart';
import 'package:pixel_adventure/game/levels/level.dart';
import 'package:pixel_adventure/game/controls/sound_button.dart';
import 'package:pixel_adventure/game/states/globalstate.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure({required this.playSoundsBackground});

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  late SoundButton soundButton;
  bool showControls = true;
  bool playSounds = true;
  bool playSoundsBackground;
  double soundVolume = 0.75;
  List<String> levelNames = [
    'Level-04',
    'Level-02',
    'Level-03',
  ];
  int currentLevel = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    _loadLevel();

    await _initBackgroundMusic();

    return super.onLoad();
  }

  @override
  void update(dt) {
    if (showControls) {
      updateJoyStick();
    }
    super.update(dt);
  }

  @override
  void onDetach() {
    FlameAudio.bgm.stop();
    super.onDetach();
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
    removeWhere((component) {
      if (component is Level) {
        component.onRemove();
      }

      return component is Level || component is CameraComponent;
    });

    if (currentLevel < levelNames.length - 1) {
      currentLevel++;
    } else {
      // no more levels
      currentLevel = 0;
    }

    _loadLevel();
  }

  void loadFromNew(){
    removeWhere((component) {
      if (component is Level) {
        component.onRemove();
      }

      return component is Level || component is CameraComponent;
    });

    currentLevel = 0;
    
    _loadLevel();
  }

  void _loadLevel() {
    try {
      // ignore: unnecessary_new
      player = new Player(character: 'Mask Dude');
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
      soundButton = SoundButton();
      cam.viewport.add(soundButton);

      if(currentLevel == 0){
        GlobalState().life = 3;
      }
      cam.viewport.add(Life());
      
    } catch (e) {
      print('Error loading level: $e');
    }
  }

  static int totalFruitCount(PixelAdventure game) {
    final fruits = game.world.children.whereType<Fruit>();
    return fruits.length;
  }

  Future<void> _initBackgroundMusic() async {
    await FlameAudio.audioCache.load('backgroundsound1.mp3');

    FlameAudio.bgm.stop();

    if (playSoundsBackground) {
      await FlameAudio.bgm.play('backgroundsound1.mp3');
    }
  }

  void toggleBackgroundMusic() {
    playSoundsBackground = !playSoundsBackground;

    if (playSoundsBackground) {
      FlameAudio.bgm.play('backgroundsound1.mp3');
    } else {
      FlameAudio.bgm.stop();
    }

    soundButton.updateSprite();
  }
}
