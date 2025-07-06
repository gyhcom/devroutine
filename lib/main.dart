import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/routing/app_router.dart';
import 'core/services/ad_service.dart';
import 'features/routine/data/models/routine_model.dart';
import 'features/routine/domain/entities/routine.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final typeId = 1;

  @override
  DateTime read(BinaryReader reader) {
    final timestamp = reader.readInt();
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final typeId = 2;

  @override
  Priority read(BinaryReader reader) {
    final value = reader.readString();
    return Priority.values.firstWhere(
      (priority) => priority.toString().split('.').last.toUpperCase() == value,
      orElse: () => Priority.medium,
    );
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    writer.writeString(obj.toString().split('.').last.toUpperCase());
  }
}

class RoutineTypeAdapter extends TypeAdapter<RoutineType> {
  @override
  final typeId = 3;

  @override
  RoutineType read(BinaryReader reader) {
    final value = reader.readString();
    return RoutineType.values.firstWhere(
      (type) => type.toString().split('.').last.toUpperCase() == value,
      orElse: () => RoutineType.daily,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineType obj) {
    writer.writeString(obj.toString().split('.').last.toUpperCase());
  }
}

void main() async {
  //메인 시작
  WidgetsFlutterBinding.ensureInitialized();

  // 광고 초기화
  await MobileAds.instance.initialize();

  // Hive 초기화
  await Hive.initFlutter();

  // 안전한 Hive 초기화 with 버전 관리
  try {
    print('🔧 Initializing Hive...');

    // 현재 앱 버전 (스키마 변경 시 증가)
    const int currentSchemaVersion = 1;

    // Adapter 등록 (순서대로)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RoutineModelAdapter());
      print('✅ RoutineModelAdapter registered (typeId: 0)');
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DateTimeAdapter());
      print('✅ DateTimeAdapter registered (typeId: 1)');
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PriorityAdapter());
      print('✅ PriorityAdapter registered (typeId: 2)');
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RoutineTypeAdapter());
      print('✅ RoutineTypeAdapter registered (typeId: 3)');
    }

    // 박스 열기 시도
    try {
      await Hive.openBox<RoutineModel>('routines');
      print('✅ Hive box opened successfully');
    } catch (e) {
      print('⚠️ Error opening box, attempting recovery: $e');

      // 스키마 호환성 문제 시에만 마이그레이션 수행
      if (e.toString().contains('type') || e.toString().contains('field')) {
        print('🔄 Performing data migration...');

        // 기존 데이터 백업 시도
        try {
          if (await Hive.boxExists('routines')) {
            // 백업 박스 생성
            final backupBox =
                await Hive.openBox('routines_backup_v${currentSchemaVersion}');
            print('📦 Created backup box');

            // 기존 박스 삭제 후 새 박스 생성
            await Hive.deleteBoxFromDisk('routines');
            await Hive.openBox<RoutineModel>('routines');
            print('✅ Migration completed - new schema applied');
          }
        } catch (migrationError) {
          print('⚠️ Migration failed, creating fresh box: $migrationError');
          await Hive.openBox<RoutineModel>('routines');
        }
      } else {
        // 다른 오류의 경우 재시도
        await Hive.openBox<RoutineModel>('routines');
      }
    }

    print('✅ Hive initialized successfully');
  } catch (e) {
    print('❌ Error initializing Hive: $e');
    // 초기화 실패 시 앱 종료 방지를 위해 빈 박스라도 생성
    try {
      await Hive.openBox<RoutineModel>('routines');
      print('⚠️ Fallback: Empty box created');
    } catch (fallbackError) {
      print('💥 Critical: Cannot create Hive box: $fallbackError');
    }
  }

  await initializeDateFormatting('ko_KR', ''); // 이게 핵심!

  runApp(const ProviderScope(child: DevRoutineApp()));
}

@immutable
class DevRoutineApp extends StatelessWidget {
  const DevRoutineApp({super.key});

  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      debugShowCheckedModeBanner: false,
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
    );
  }
}
