import 'package:equatable/equatable.dart';
import 'package:pixel_adventure/models/user_model.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccessfully extends RegisterState {
  final UserModel userModel;

  const RegisterSuccessfully({required this.userModel});

  @override
  List<Object> get props => [userModel];
}

class RegisterFailed extends RegisterState {
  final String message;

  const RegisterFailed(this.message);

  @override
  List<Object> get props => [message];
}
