import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../theme/app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeData build() {
    return AppTheme.getDarkTheme();
  }

  void toggleTheme() {
    // 현재는 다크 테마만 지원하므로 토글 기능은 비활성화
    // 추후 라이트 테마 추가 시 구현
  }
}
