import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/viewModels/player/player_cubit.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';
import 'package:sprite/sprite.dart';

class SelectCharacterScreen extends StatefulWidget {
  const SelectCharacterScreen({super.key});

  @override
  State<SelectCharacterScreen> createState() => _SelectCharacterScreenState();
}

class _SelectCharacterScreenState extends State<SelectCharacterScreen> {
  final List<String> characters = [
    'assets/images/Main Characters/Mask Dude/Idle (32x32).png',
    'assets/images/Main Characters/Ninja Frog/Idle (32x32).png',
    'assets/images/Main Characters/Pink Man/Idle (32x32).png',
    'assets/images/Main Characters/Virtual Guy/Idle (32x32).png',
  ];

  int selectedCharacter = 0;

  void _handleOntapLeft() {
    setState(() {
      selectedCharacter = selectedCharacter == 0
          ? characters.length - 1
          : selectedCharacter - 1;
    });
  }

  void _handleOntapRight() {
    setState(() {
      selectedCharacter = selectedCharacter == characters.length - 1
          ? 0
          : selectedCharacter + 1;
    });
  }

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
                Text(
                  characters[selectedCharacter].split('/')[3],
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _handleOntapLeft,
                      child: const Icon(
                        Icons.arrow_left_rounded,
                        size: 160,
                        color: Colors.white,
                      ),
                    ),
                    Sprite(
                      imagePath: characters[selectedCharacter],
                      size: const Size(32, 32),
                      amount: 11,
                      scale: 4,
                      stepTime: 60,
                    ),
                    GestureDetector(
                      onTap: _handleOntapRight,
                      child: const Icon(
                        Icons.arrow_right_rounded,
                        size: 160,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: () {
                    context.read<PlayerCutbit>().changePlayer(
                          playerName:
                              characters[selectedCharacter].split('/')[3],
                        );
                    Navigator.of(context).pop();
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
                      'Chọn',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF211F30),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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