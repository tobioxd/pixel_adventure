import 'package:equatable/equatable.dart';
import 'package:pixel_adventure/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel userModel;

  const ProfileLoaded({required this.userModel});

  @override
  List<Object> get props => [userModel];
}

class ProfileRequireLogin extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileLogout extends ProfileState {}
