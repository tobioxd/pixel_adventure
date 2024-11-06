import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/commons/widgets/app_button.dart';
import 'package:pixel_adventure/commons/widgets/high_light_text.dart';
import 'package:pixel_adventure/viewModels/profile/profile_cubit.dart';
import 'package:pixel_adventure/viewModels/profile/profile_state.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';
import 'package:pixel_adventure/views/user_infor/change_password_screen.dart';
import 'package:pixel_adventure/views/user_infor/edit_user_infor_screen.dart';

class UserInforScreen extends StatefulWidget {
  const UserInforScreen({super.key});

  @override
  State<UserInforScreen> createState() => _UserInforScreenState();
}

class _UserInforScreenState extends State<UserInforScreen> {
  @override
  void initState() {
    context.read<ProfileCubit>().loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          BlocConsumer<ProfileCubit, ProfileState>(
            buildWhen: (previous, current) =>
                current is ProfileLoaded || current is ProfileInitial,
            builder: (context, state) {
              if (state is ProfileLoaded) {
                final day = state.userModel.createdAt.day < 10
                    ? '0${state.userModel.createdAt.day}'
                    : state.userModel.createdAt.day;
                final month = state.userModel.createdAt.month < 10
                    ? '0${state.userModel.createdAt.month}'
                    : state.userModel.createdAt.month;
                final year = state.userModel.createdAt.year;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 140),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                base64Decode(state.userModel.photo),
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${state.userModel.id}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  HighLightText(
                                    text: state.userModel.name,
                                    fontSize: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Email: ${state.userModel.email}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ngày tham gia: $day/$month/$year',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final cubit = context.read<ProfileCubit>();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProvider<ProfileCubit>.value(
                                          value: cubit,
                                          child: const EditUserInforScreen(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              buttonText: "Đổi mật khẩu",
                              onTap: () {
                                final cubit = context.read<ProfileCubit>();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BlocProvider<ProfileCubit>.value(
                                      value: cubit,
                                      child: const ChangePasswordScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            listener: (context, state) {
              if (state is ProfileLogout) {
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
            },
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
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                context.read<ProfileCubit>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
