// lib/screens/start_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/viewModels/player/player_cubit.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';
import 'package:pixel_adventure/views/game/pixel_adventure.dart';
import 'package:pixel_adventure/views/select_character/select_character_screen.dart';
import 'package:sprite/sprite.dart';

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
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => GameWidget(
                                  game: PixelAdventure(
                                    context: context,
                                    playSoundsBackground:
                                        context.read<SoundCubit>().state,
                                    playerName:
                                        context.read<PlayerCutbit>().state,
                                  ),
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          buttonText: "Chơi ngay",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          buttonText: "Lịch sử",
                          onTap: () {},
                        ),
                      ),
                    ],
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
            child: Column(
              children: [
                IconButton(
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
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SelectCharacterScreen(),
                      ),
                    );
                  },
                  child: BlocBuilder<PlayerCutbit, String>(
                    builder: (context, state) {
                      return Sprite(
                        imagePath:
                            'assets/images/Main Characters/${context.read<PlayerCutbit>().state}/Idle (32x32).png',
                        size: const Size(32, 32),
                        amount: 11,
                        scale: 2,
                        stepTime: 60,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
