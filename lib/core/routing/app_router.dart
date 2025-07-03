import 'package:auto_route/auto_route.dart';
import 'package:devroutine/features/routine/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../features/routine/domain/entities/routine.dart';
import '../../features/routine/presentation/screens/routine_form_screen.dart';
import '../../features/routine/presentation/screens/routine_list_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: DashboardRoute.page,
          initial: true, // 여기에 initial: true 추가
          path: '/', // 메인 경로로 변경
        ),
        AutoRoute(
          page: RoutineListRoute.page,
          path: '/routines', // initial: true 제거
        ),
        AutoRoute(
          page: RoutineFormRoute.page,
          path: '/routine-form',
        ),
      ];
}
