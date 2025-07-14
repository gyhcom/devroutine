import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/routing/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/onboarding_provider.dart';
import 'core/services/notification_service.dart';
import 'features/routine/data/models/routine_model.dart';
import 'features/routine/domain/entities/routine.dart';
import 'features/splash/splash_screen.dart';

// Priority Adapter
class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final typeId = 1;

  @override
  Priority read(BinaryReader reader) {
    final value = reader.readString();
    switch (value) {
      case 'HIGH':
        return Priority.high;
      case 'MEDIUM':
        return Priority.medium;
      case 'LOW':
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.high:
        writer.writeString('HIGH');
        break;
      case Priority.medium:
        writer.writeString('MEDIUM');
        break;
      case Priority.low:
        writer.writeString('LOW');
        break;
    }
  }
}

// RoutineType Adapter
class RoutineTypeAdapter extends TypeAdapter<RoutineType> {
  @override
  final typeId = 2;

  @override
  RoutineType read(BinaryReader reader) {
    final value = reader.readString();
    switch (value) {
      case 'DAILY':
        return RoutineType.daily;
      case 'THREE_DAY':
        return RoutineType.threeDay;
      default:
        return RoutineType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RoutineType obj) {
    switch (obj) {
      case RoutineType.daily:
        writer.writeString('DAILY');
        break;
      case RoutineType.threeDay:
        writer.writeString('THREE_DAY');
        break;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Locale 초기화 (한국어)
    await initializeDateFormatting('ko_KR', '');

    // Hive 초기화
    await Hive.initFlutter();

    // 기존 박스 삭제 (TypeId 충돌 해결)
    if (await Hive.boxExists('routines')) {
      await Hive.deleteBoxFromDisk('routines');
    }

    // Hive Adapter 등록 (올바른 TypeId 사용)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RoutineModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RoutineTypeAdapter());
    }

    // 새 박스 열기
    await Hive.openBox<RoutineModel>('routines');

    if (kDebugMode) {
      print('✅ Hive 초기화 완료');
    }

    // 알림 서비스 초기화
    await NotificationService().initialize();

    if (kDebugMode) {
      print('✅ 알림 서비스 초기화 완료');
    }

    runApp(
      ProviderScope(
        child: DevRoutineApp(),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print('❌ 앱 초기화 실패: $e');
    }

    // 에러가 발생해도 앱을 실행
    runApp(
      ProviderScope(
        child: DevRoutineApp(),
      ),
    );
  }
}

class DevRoutineApp extends ConsumerWidget {
  DevRoutineApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);

    // 온보딩 프로바이더 강제 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print('🔄 [MAIN] 온보딩 프로바이더 강제 초기화');
      }
      ref.read(onboardingProvider.notifier);
    });

    if (kDebugMode) {
      print('🏗️ [MAIN] DevRoutineApp build 메서드 호출됨');
    }

    return MaterialApp.router(
      title: 'DevRoutine',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: _appRouter.config(),
    );
  }
}
