import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/viewModels/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
}
