import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/app_text_form_field.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/register/register_cubit.dart';
import 'package:pixel_adventure/viewModels/register/register_state.dart';
import 'package:pixel_adventure/viewModels/user/user_cubit.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nameController;
  File? _image;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể chọn ảnh')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 140, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const HighLightText(
                      text: "Đăng Ký",
                      fontSize: 32,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _image == null
                            ? const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      controller: _nameController,
                      hintText: "Tên hiển thị",
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    AppTextFormField(
                      controller: _confirmPasswordController,
                      hintText: "Xác nhận mật khẩu",
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocConsumer<RegisterCubit, RegisterState>(
                      listener: (context, state) {
                        if (state is RegisterSuccessfully) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Đăng ký thành công!')),
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => UserCubit(),
                                child: const StartScreen(),
                              ),
                            ),
                            (route) => false,
                          );
                        } else if (state is RegisterFailed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                onTap: state is RegisterLoading
                                    ? () {}
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          context
                                              .read<RegisterCubit>()
                                              .register(
                                                email: _emailController.text,
                                                password:
                                                    _passwordController.text,
                                                confirmPassword:
                                                    _confirmPasswordController
                                                        .text,
                                                name: _nameController.text,
                                                image: _image,
                                              );
                                        }
                                      },
                                buttonText: state is RegisterLoading
                                    ? 'Đang xử lý...'
                                    : 'Đăng ký',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
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
