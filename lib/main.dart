import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_sizes.dart';
import 'core/constants/app_fonts.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DevRoutineApp(),
    ),
  );
}

class DevRoutineApp extends StatelessWidget {
  const DevRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevRoutine',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        textTheme: GoogleFonts.sourceCodeProTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.onPrimary,
          onSecondary: AppColors.onSecondary,
          onSurface: AppColors.onSurface,
          onBackground: AppColors.onBackground,
          onError: AppColors.onError,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: AppColors.background,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        cardColor: AppColors.surfaceLight,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DevRoutine',
          style: GoogleFonts.sourceCodePro(
            fontWeight: AppFonts.bold,
            fontSize: AppFonts.h3,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.xl),
              Text(
                'DevRoutine',
                style: GoogleFonts.sourceCodePro(
                  fontSize: AppFonts.h1,
                  fontWeight: AppFonts.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              _buildEmptyState(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 루틴 추가 화면으로 이동
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: AppSizes.iconLg * 2,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              '아직 등록된 루틴이 없습니다',
              style: GoogleFonts.sourceCodePro(
                fontSize: AppFonts.body,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              '새로운 루틴을 추가해보세요',
              style: GoogleFonts.sourceCodePro(
                fontSize: AppFonts.caption,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
