import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  final String status;

  const LoadingScreen({super.key, this.status = "Cargando datos..."});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pokeball.png',
              width: 100,
              height: 100,
              color: AppColors.selectedGen,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppColors.selectedGen,
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: AppColors.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
