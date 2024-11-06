import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/app_text_form_field.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/profile/profile_cubit.dart';
import 'package:pixel_adventure/viewModels/profile/profile_state.dart';
import 'package:pixel_adventure/viewModels/user/user_cubit.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';

class EditUserInforScreen extends StatefulWidget {
  const EditUserInforScreen({super.key});

  @override
  State<EditUserInforScreen> createState() => _EditUserInforScreenState();
}

class _EditUserInforScreenState extends State<EditUserInforScreen> {
  late TextEditingController _nameController;
  late ImagePicker _picker;
  File? _image;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  initState() {
    _picker = ImagePicker();
    final state = context.read<ProfileCubit>().state as ProfileLoaded;
    _nameController = TextEditingController(text: state.userModel.name);
    super.initState();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
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
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 200,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HighLightText(
                        text: "Chỉnh Sửa Thông Tin",
                        fontSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.memory(
                                base64Decode((context.read<ProfileCubit>().state
                                        as ProfileLoaded)
                                    .userModel
                                    .photo),
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          controller: _nameController,
                          hintText: "Tên hiển thị",
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Vui lòng nhập tên'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<ProfileCubit, ProfileState>(
                      listener: (context, state) {
                    if (state is ProfileRequireLogin) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ),
                        (route) => false,
                      );
                    }
                    if (state is ProfileError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                        ),
                      );
                    }
                    if (state is ProfileLoaded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật thông tin thành công'),
                        ),
                      );
                      context.read<UserCubit>().loadUser();
                      Navigator.of(context).pop();
                    }
                  }, builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            onTap: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<ProfileCubit>().updateProfile(
                                      name: _nameController.text,
                                      photo: _image,
                                    );
                              }
                            },
                            buttonText: 'Lưu thay đổi',
                          ),
                        ),
                      ],
                    );
                  }),
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
