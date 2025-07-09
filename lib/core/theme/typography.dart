import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_fonts.dart';

class AppTypography {
  AppTypography._();

  /// Google Fonts를 안전하게 사용하는 헬퍼 함수
  static TextStyle safeGoogleFont({
    required String fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    List<String>? fallbackFonts,
  }) {
    try {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      ).copyWith(
        fontFamilyFallback: fallbackFonts ?? _defaultFallbackFonts,
      );
    } catch (e) {
      // Google Fonts 로딩 실패 시 기본 폰트 사용
      return TextStyle(
        fontFamily: _defaultFontFamily,
        fontFamilyFallback: _defaultFallbackFonts,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  /// 안전한 Noto Sans 폰트
  static TextStyle safeNotoSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return safeGoogleFont(
      fontFamily: 'Noto Sans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // 기본 폰트 설정
  static const String _defaultFontFamily = 'SF Pro Display';
  static const List<String> _defaultFallbackFonts = [
    'SF Pro Display',
    'Helvetica Neue',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  // 미리 정의된 텍스트 스타일들
  static TextStyle get displayLarge => safeNotoSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get displayMedium => safeNotoSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headlineLarge => safeNotoSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => safeNotoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => safeNotoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => safeNotoSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyLarge => safeNotoSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => safeNotoSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => safeNotoSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get labelLarge => safeNotoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelMedium => safeNotoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => safeNotoSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );

  /// TextTheme을 반환하는 메서드
  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
