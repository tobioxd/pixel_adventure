import 'dart:async';

import 'package:fixel_adventure/levels/level.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  runApp(
    GameWidget(
      game: PixelAdventure(),
    ),
  );
}

class PixelAdventure extends FlameGame {
  late final CameraComponent gameCamera;
  late final World gameWorld;

  @override
  Color backgroundColor() {
    return const Color(0xff211f30);
  }

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    gameWorld = Level(levelName: 'Level-02');
    gameCamera = CameraComponent.withFixedResolution(
      world: gameWorld,
      width: 640,
      height: 360,
    );
    gameCamera.viewfinder.anchor = Anchor.topLeft;
    addAll([
      gameWorld,
      gameCamera,
    ]);
    return super.onLoad();
  }
}
