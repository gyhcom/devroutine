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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.onPrimary,
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
          ),
        ),
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
      backgroundColor: AppColors.background,
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
                '오늘의 루틴',
                style: GoogleFonts.sourceCodePro(
                  fontSize: AppFonts.h1,
                  fontWeight: AppFonts.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                '아직 등록된 루틴이 없습니다.',
                style: GoogleFonts.sourceCodePro(
                  fontSize: AppFonts.body,
                  color: AppColors.onBackground.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 루틴 추가 화면으로 이동
                  },
                  child: Text(
                    '루틴 추가하기',
                    style: GoogleFonts.sourceCodePro(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
