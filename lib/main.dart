import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/game/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(const Game());
}

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pixel Adventure',
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}
