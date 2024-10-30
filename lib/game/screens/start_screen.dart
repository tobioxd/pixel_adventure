// lib/screens/start_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/game/screens/pixel_adventure.dart';
import 'package:pixel_adventure/game/screens/select_character_screen.dart';
import 'package:pixel_adventure/game/states/player_cubit.dart';
import 'package:pixel_adventure/game/states/sound_cubit.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'Pixel Adventure',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 20.0,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //     builder: (context) => GameWidget(
                    //       game: PixelAdventure(
                    //         playSoundsBackground:
                    //             context.read<SoundCubit>().state,
                    //         playerName: 'Mask Dude',
                    //       ),
                    //     ),
                    //   ),
                    //   (route) => false,
                    // );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => GameWidget(
                          game: PixelAdventure(
                            playSoundsBackground:
                                context.read<SoundCubit>().state,
                            playerName: context.read<PlayerCutbit>().state,
                          ),
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Chơi ngay',
                      style: TextStyle(
                        fontSize: 25,
                        color: Color(0xFF211F30),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SelectCharacterScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: BlocBuilder<PlayerCutbit, String>(
                      builder: (context, state) {
                        return Text(
                          context.read<PlayerCutbit>().state,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF211F30),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: () {
                context.read<SoundCubit>().toggleSound();
              },
              icon: BlocBuilder<SoundCubit, bool>(
                builder: (context, state) {
                  return Icon(
                    state == true ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 40,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
