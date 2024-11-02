import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/game_result/game_result_cubit.dart';
import 'package:pixel_adventure/viewModels/game_result/game_result_state.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int points;
  final Duration duration;
  final String character;

  const GameOverScreen({
    required this.character,
    super.key,
    required this.points,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<GameResultCubit>().saveResultToDevice(
            time: duration.inSeconds,
            character: character,
            points: points,
          );
    });
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HighLightText(
              text: "Kết thúc",
              fontSize: 44,
            ),
            const SizedBox(
              height: 40,
            ),
            BlocBuilder<GameResultCubit, GameResultState>(
              builder: (context, state) {
                if (state is GameResultFailure) {
                  return SizedBox(
                    width: 600,
                    child: Text(state.message),
                  );
                }
                return SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      Row(children: [
                        const Text(
                          "Nhân vật:",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          character,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                      Row(children: [
                        const Text(
                          "Điểm:",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          points.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                      Row(children: [
                        const Text(
                          "Thời gian:",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${duration.inMinutes} phút ${duration.inSeconds % 60} giây",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
            AppButton(
              buttonText: "Về trang chủ",
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const StartScreen(),
                  ),
                  (route) => false,
                );
                context
                    .read<SoundCubit>()
                    .playSound(context.read<SoundCubit>().state);
              },
            ),
          ],
        ),
      ),
    );
  }
}
