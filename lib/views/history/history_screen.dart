import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/models/score_model.dart';
import 'package:pixel_adventure/viewModels/history/history_cubit.dart';
import 'package:pixel_adventure/viewModels/history/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Widget _dataRow(
      {required ScoreModel score, required int length, required int index}) {
    String year = '${score.createdAt.year}';
    String month = score.createdAt.month < 10
        ? '0${score.createdAt.month}'
        : '${score.createdAt.month}';
    String day = score.createdAt.day < 10
        ? '0${score.createdAt.day}'
        : '${score.createdAt.day}';
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(
            color: Colors.white,
            width: 1,
          ),
          left: const BorderSide(
            color: Colors.white,
            width: 1,
          ),
          right: const BorderSide(
            color: Colors.white,
            width: 1,
          ),
          bottom: BorderSide(
            color: index == length - 1 ? Colors.white : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      width: 600,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '$day/$month/$year',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  score.character,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '${score.points}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  score.time.inMinutes == 0
                      ? '${score.time.inSeconds}s'
                      : '${score.time.inMinutes}p ${score.time.inSeconds % 60}s',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      HighLightText(
                        text: "Lịch sử",
                        fontSize: 32,
                      ),
                      SizedBox(height: 80),
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ],
                  );
                }
                return SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        const HighLightText(
                          text: "Lịch sử",
                          fontSize: 32,
                        ),
                        const SizedBox(height: 32),
                        Column(
                          children: [
                            if (state is HistoryLoaded)
                              ...state.scores.map((score) {
                                return _dataRow(
                                  score: score,
                                  length: state.scores.length,
                                  index: state.scores.indexOf(score),
                                );
                              }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
