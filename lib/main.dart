import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';
import 'package:pixel_adventure/firebase_options.dart';
import 'package:pixel_adventure/viewModels/player/player_cubit.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();
  NetWorkService.subcripeToConnectivityChanges();
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
