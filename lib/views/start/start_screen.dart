import 'dart:convert';
import 'dart:developer';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/viewModels/history/history_cubit.dart';
import 'package:pixel_adventure/viewModels/player/player_cubit.dart';
import 'package:pixel_adventure/viewModels/profile/profile_cubit.dart';
import 'package:pixel_adventure/viewModels/ranking/ranking_cubit.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';
import 'package:pixel_adventure/viewModels/user/user_cubit.dart';
import 'package:pixel_adventure/viewModels/user/user_state.dart';
import 'package:pixel_adventure/views/auth/auth_screen.dart';
import 'package:pixel_adventure/views/game/pixel_adventure.dart';
import 'package:pixel_adventure/views/history/history_screen.dart';
import 'package:pixel_adventure/views/ranking/ranking_screen.dart';
import 'package:pixel_adventure/views/select_character/select_character_screen.dart';
import 'package:pixel_adventure/views/user_infor/user_infor_screen.dart';
import 'package:sprite/sprite.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    context.read<UserCubit>().loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const HighLightText(
                  text: "Pixel Adventure",
                  fontSize: 50,
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
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BlocProvider<HistoryCubit>(
                                create: (BuildContext context) =>
                                    getIt<HistoryCubit>()..loadHistory(),
                                child: const HistoryScreen(),
                              ),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<UserCubit, UserState>(
                  buildWhen: (previous, current) => current is UserLoaded,
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      log(state.user.photo);
                      return GestureDetector(
                        onTap: () {
                          if (state.user.id == 'null') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => getIt<ProfileCubit>(),
                                  child: const UserInforScreen(),
                                ),
                              ),
                            );
                          }
                        },
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  base64Decode(state.user.photo),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (state.user.id != 'null')
                                    Text(
                                      'id: ${state.user.id}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  Text(
                                    state.user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(
                    Icons.leaderboard,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<RankingCubit>(
                          create: (BuildContext context) =>
                              getIt<RankingCubit>(),
                          child: const RankingScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
