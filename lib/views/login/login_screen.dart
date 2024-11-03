import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/app_text_form_field.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/login/login_cubit.dart';
import 'package:pixel_adventure/viewModels/login/login_state.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: BlocConsumer<LoginCubit, LoginState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 140, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const HighLightText(
                          text: "Đăng Nhập",
                          fontSize: 32,
                        ),
                        const SizedBox(height: 32),
                        AppTextFormField(
                          controller: _emailController,
                          hintText: "Email",
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value!)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextFormField(
                          controller: _passwordController,
                          hintText: "Mật khẩu",
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value!.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                onTap: state is LoginLoading
                                    ? () {}
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          context.read<LoginCubit>().login(
                                                email: _emailController.text,
                                                password:
                                                    _passwordController.text,
                                              );
                                        }
                                      },
                                buttonText: state is LoginLoading
                                    ? 'Đang xử lý...'
                                    : 'Đăng nhập',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
              listener: (BuildContext context, LoginState state) {
                if (state is LoginFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is LoginSuccess) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const StartScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
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
