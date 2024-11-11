import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/ranking/ranking_cubit.dart';
import 'package:pixel_adventure/viewModels/ranking/ranking_state.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    context.read<RankingCubit>().loadRanking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          BlocConsumer<RankingCubit, RankingState>(
            buildWhen: (previous, current) =>
                current is RankingLoading || current is RankingLoaded,
            listener: (context, state) {
              if (state is RankingFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is RankingLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      const HighLightText(text: "Bảng xếp hạng", fontSize: 32),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const SizedBox(width: 50), // Space for rank number
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Tên',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Điểm',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Thời gian',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Ngày',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(
                        state.rankings.length,
                        (index) {
                          final user = state.rankings.keys.elementAt(index);
                          final score = state.rankings.values.elementAt(index);
                          final day = score.createdAt.day;
                          final month = score.createdAt.month;
                          final year = score.createdAt.year;
                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: _getMedalColor(index),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      score.points.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${score.time.inSeconds}s',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '$day/$month/$year',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }
              return SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    const HighLightText(text: "Bảng xếp hạng", fontSize: 32),
                    const Spacer(),
                    CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const Spacer(),
                  ],
                ),
              );
            },
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

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Huy chương vàng
      case 1:
        return Colors.grey[400]!; // Huy chương bạc
      case 2:
        return Colors.brown; // Huy chương đồng
      default:
        return Colors.blue.withOpacity(0.7); // Các hạng khác
    }
  }
}
