import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/viewModels/login/login_cubit.dart';
import 'package:pixel_adventure/viewModels/register/register_cubit.dart';
import 'package:pixel_adventure/views/login/login_screen.dart';
import 'package:pixel_adventure/views/register/register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BlocProvider<LoginCubit>(
                                create: (context) => getIt<LoginCubit>(),
                                child: const LoginScreen(),
                              ),
                            ));
                          },
                          buttonText: "Đăng nhập",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BlocProvider<RegisterCubit>(
                                create: (context) => getIt<RegisterCubit>(),
                                child: const RegisterScreen(),
                              ),
                            ));
                          },
                          buttonText: "Đăng Ký",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
