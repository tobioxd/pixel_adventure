import 'package:equatable/equatable.dart';
import 'package:pixel_adventure/models/score_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {
  final List<ScoreModel> scores = [];

  HistoryInitial();

  @override
  List<Object> get props => [scores];
}

class HistoryLoaded extends HistoryState {
  final List<ScoreModel> scores;

  const HistoryLoaded(this.scores);

  @override
  List<Object> get props => [scores];
}

class HistoryLoading extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
