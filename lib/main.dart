import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/core/services/get_it_service.dart';
import 'package:pixel_adventure/game/screens/start_screen.dart';
import 'package:pixel_adventure/game/states/player_cubit.dart';
import 'package:pixel_adventure/game/states/sound_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(const Game());
}

// new push
class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SoundCubit>(
          create: (context) => getIt<SoundCubit>(),
        ),
        BlocProvider<PlayerCutbit>(
          create: (context) => getIt<PlayerCutbit>(),
        ),
      ],
      child: const MaterialApp(
        title: 'Pixel Adventure',
        debugShowCheckedModeBanner: false,
        home: StartScreen(),
      ),
    );
  }
}
