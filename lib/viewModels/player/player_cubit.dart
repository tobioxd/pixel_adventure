import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerCutbit extends Cubit<String> {
  PlayerCutbit() : super('Mask Dude');

  void changePlayer({required String playerName}) {
    emit(playerName);
  }
}
