import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/viewModels/profile/profile_cubit.dart';
import 'package:pixel_adventure/viewModels/profile/profile_state.dart';
import 'package:pixel_adventure/views/start/start_screen.dart';

class UserInforScreen extends StatefulWidget {
  const UserInforScreen({super.key});

  @override
  State<UserInforScreen> createState() => _UserInforScreenState();
}

class _UserInforScreenState extends State<UserInforScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        children: [
          Center(
            child: BlocConsumer<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return Column(
                  children: [],
                );
              },
              listener: (context, state) {
                if (state is ProfileRequireLogin || state is ProfileLogout) {
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
