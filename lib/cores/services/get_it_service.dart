import 'package:get_it/get_it.dart';
import 'package:pixel_adventure/viewModels/player/player_cubit.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  getIt.registerFactory(() => SoundCubit());
  getIt.registerFactory(() => PlayerCutbit());
}
