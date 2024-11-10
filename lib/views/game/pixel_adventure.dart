import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/views/game/controls/down_button.dart';
import 'package:pixel_adventure/views/game/controls/jump_button.dart';
import 'package:pixel_adventure/views/game/controls/life.dart';
import 'package:pixel_adventure/views/game/controls/sound_button.dart';
import 'package:pixel_adventure/views/game/items/fruit.dart';
import 'package:pixel_adventure/views/game/levels/level.dart';
import 'package:pixel_adventure/views/game/players/player.dart';
import 'package:pixel_adventure/views/game/states/globalstate.dart';
import 'package:pixel_adventure/views/game_over/game_over_screen.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure({
    required this.playSoundsBackground,
    required String playerName,
    required this.context,
  }) {
    GlobalState().playerName = playerName;
  }

  final BuildContext context;
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: GlobalState().playerName);
  late JoystickComponent joystick;
  late SoundButton soundButton;
  bool showControls = true;
  bool playSounds = true;
  bool playSoundsBackground;
  double soundVolume = 0.75;
  List<String> levelNames = [
    'Level-01',
    'Level-02',
    'Level-03',
    'Level-04',
  ];
  int currentLevel = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    _initializeCameraWithControls();
    loadFromNew();

    await _initBackgroundMusic();

    return super.onLoad();
  }

  void _initializeCameraWithControls() {
    cam = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    add(cam);

    // Thêm joystick vào camera viewport
    joystick = JoystickComponent(
      priority: 1,
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
      margin: const EdgeInsets.only(left: 40, bottom: 35),
    );
    cam.viewport.add(joystick);

    // Thêm các nút điều khiển vào camera viewport
    cam.viewport.add(JumpButton());
    cam.viewport.add(DownButton());

    // Thêm soundButton vào camera viewport
    soundButton = SoundButton();
    cam.viewport.add(soundButton);

    // Thêm Life vào camera viewport
    cam.viewport.add(Life());
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
      return component is Level;
    });

    if (currentLevel < levelNames.length - 1) {
      currentLevel++;
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            points: GlobalState().point,
            duration: GlobalState().getElapsedTime(),
            character: GlobalState().playerName,
          ),
        ),
      );
      return;
    }

    _loadLevel();
  }

  void loadFromNew() {
    removeWhere((component) {
      if (component is Level) {
        component.onRemove();
      }
      return component is Level;
    });

    print(GlobalState().point);
    GlobalState().resetPoint();
    currentLevel = 0;

    _loadLevel();
  }

  void _loadLevel() {
    try {
      player = Player(character: GlobalState().playerName);

      Level world = Level(
        player: player,
        levelName: levelNames[currentLevel],
      );

      add(world);

      cam.world = world;

      if (currentLevel == 0) {
        GlobalState().resetLife();
        GlobalState().resetPoint();
        GlobalState().start();
      }

      resetHearts();

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

  void resetHearts() {
    cam.viewport.children.removeWhere((component) => component is Life);

    final life = Life();
    cam.viewport.add(life);

    life.updateHearts();
  }
}
