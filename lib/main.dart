import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/routing/app_router.dart';
import 'features/routine/data/models/routine_model.dart';
import 'features/routine/domain/entities/routine.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(RoutineModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DateTimeAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PriorityAdapter());
  }

  await Hive.deleteBoxFromDisk('routines');
  await Hive.openBox<RoutineModel>('routines');

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
