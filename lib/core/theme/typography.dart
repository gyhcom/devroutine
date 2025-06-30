import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.sourceCodePro(
        fontSize: AppFonts.h1,
        fontWeight: AppFonts.bold,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.sourceCodePro(
        fontSize: AppFonts.h2,
        fontWeight: AppFonts.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.sourceCodePro(
        fontSize: AppFonts.h3,
        fontWeight: AppFonts.semiBold,
        letterSpacing: 0,
      ),
      bodyLarge: GoogleFonts.sourceCodePro(
        fontSize: AppFonts.body,
        fontWeight: AppFonts.regular,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.sourceCodePro(
        fontSize: AppFonts.caption,
        fontWeight: AppFonts.regular,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.sourceCodePro(
        fontSize: AppFonts.small,
        fontWeight: AppFonts.regular,
        letterSpacing: 0.4,
      ),
    );
  }
}
