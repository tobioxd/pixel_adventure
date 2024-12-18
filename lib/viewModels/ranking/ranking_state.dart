import 'package:equatable/equatable.dart';
import 'package:pixel_adventure/models/score_model.dart';
import 'package:pixel_adventure/models/user_model.dart';

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object> get props => [];
}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingFailed extends RankingState {
  final String message;

  const RankingFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class RankingLoaded extends RankingState {
  final Map<UserModel, ScoreModel> rankings;

  const RankingLoaded({required this.rankings});

  @override
  List<Object> get props => [rankings];
}
