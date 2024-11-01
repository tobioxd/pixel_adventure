import 'dart:developer';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SoundCubit extends Cubit<bool> {
  SoundCubit() : super(true) {
    FlameAudio.bgm.play('backgroundsound1.mp3');
  }

  void toggleSound() {
    log("music paying = $state");
    if (state == false) {
      FlameAudio.bgm.play('backgroundsound1.mp3');
    } else {
      FlameAudio.bgm.stop();
    }
    emit(!state);
  }
}
