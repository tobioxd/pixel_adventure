import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/game/enemies/rhino.dart';
import 'package:pixel_adventure/game/uis/background_tile.dart';
import 'package:pixel_adventure/game/components/checkpoint.dart';
import 'package:pixel_adventure/game/enemies/chicken.dart';
import 'package:pixel_adventure/game/components/collision_block.dart';
import 'package:pixel_adventure/game/obstacles/fire.dart';
import 'package:pixel_adventure/game/items/fruit.dart';
import 'package:pixel_adventure/game/states/globalstate.dart';
import 'package:pixel_adventure/game/players/player.dart';
import 'package:pixel_adventure/game/obstacles/saw.dart';
import 'package:pixel_adventure/game/obstacles/saw1.dart';
import 'package:pixel_adventure/game/obstacles/saw2.dart';
import 'package:pixel_adventure/game/obstacles/saw3.dart';
import 'package:pixel_adventure/game/screens/pixel_adventure.dart';

class Level extends World
    with HasGameRef<PixelAdventure>, DragCallbacks, HasCollisionDetection {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  void onRemove() {
    collisionBlocks.clear();
    level.removeFromParent();
    super.onRemove();
  }

  @override
  FutureOr<void> onLoad() async {
    // Reset numberFruits to 0 when a new map is loaded
    GlobalState().numberFruits = 0;

    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _addCollisions();
    _spawningObjects();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    const tileSize = 64;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          final tile = BackgroundTile(
            color: backgroundColor,
            position: Vector2(x * tileSize, y * tileSize),
          );
          add(tile);
        }
      }
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            GlobalState().numberFruits++;
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Saw1':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw1(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Saw2':
            final offNeg = spawnPoint.properties.getValue('offNeg') ?? 0.0;
            final offPos = spawnPoint.properties.getValue('offPos') ?? 0.0;
            final verticalOffset =
                spawnPoint.properties.getValue('verticalOffset') ?? 2.0;
            final saw = Saw2(
              offNeg: offNeg,
              offPos: offPos,
              verticalOffset: verticalOffset,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Saw3':
            final offNeg = spawnPoint.properties.getValue('offNeg') ?? 0.0;
            final offPos = spawnPoint.properties.getValue('offPos') ?? 0.0;
            final verticalOffset =
                spawnPoint.properties.getValue('verticalOffset') ?? 2.0;
            final saw = Saw3(
              offNeg: offNeg,
              offPos: offPos,
              verticalOffset: verticalOffset,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(chicken);
            break;
          case 'Rhino':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final rhino = Rhino(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(rhino);
            break;
          case 'Fire':
            final fire = Fire(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(fire);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
