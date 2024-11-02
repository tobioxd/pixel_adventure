import 'package:equatable/equatable.dart';

abstract class GameResultState extends Equatable {
  const GameResultState();

  @override
  List<Object> get props => [];
}

class GameResultInitial extends GameResultState {}

class GameResultSuccess extends GameResultState {}

class GameResultFailure extends GameResultState {
  final String message;

  const GameResultFailure(this.message);

  @override
  List<Object> get props => [message];
}
