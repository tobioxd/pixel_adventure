import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/app_text_form_field.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/profile/profile_cubit.dart';
import 'package:pixel_adventure/viewModels/profile/profile_state.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  initState() {
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Vui lòng nhập mật khẩu cũ';
    }
    if (value!.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 140),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HighLightText(
                        text: "Đổi mật khẩu",
                        fontSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          controller: _oldPasswordController,
                          hintText: "Mật khẩu cũ",
                          validator: _validatePassword,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          controller: _newPasswordController,
                          hintText: "Mật khẩu mới",
                          validator: _validatePassword,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          controller: _confirmPasswordController,
                          hintText: "Nhập lại mật khẩu mới",
                          validator: _validatePassword,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocListener<ProfileCubit, ProfileState>(
                    listener: (context, state) {
                      if (state is ProfileError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                          ),
                        );
                      }
                      if (state is ProfileRequireLogin) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const StartScreen(),
                          ),
                          (route) => false,
                        );
                      }
                      if (state is ProfileChangePasswordSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đổi mật khẩu thành công"),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            buttonText: "Đổi mật khẩu",
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ProfileCubit>().changePassword(
                                      currentPassword:
                                          _oldPasswordController.text,
                                      newPassword: _newPasswordController.text,
                                      confirmNewPassword:
                                          _confirmPasswordController.text,
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
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
