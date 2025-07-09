import 'package:auto_route/auto_route.dart';
import 'package:devroutine/features/routine/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../features/routine/domain/entities/routine.dart';
import '../../features/routine/presentation/screens/routine_form_screen.dart';
import '../../features/routine/presentation/screens/routine_list_screen.dart';
import '../../features/routine/presentation/screens/routine_detail_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          initial: true,
          path: '/splash',
        ),
        AutoRoute(
          page: OnboardingRoute.page,
          path: '/onboarding',
        ),
        AutoRoute(
          page: DashboardRoute.page,
          path: '/',
        ),
        AutoRoute(
          page: RoutineListRoute.page,
          path: '/routines',
        ),
        AutoRoute(
          page: RoutineFormRoute.page,
          path: '/routine-form',
        ),
        AutoRoute(
          page: RoutineDetailRoute.page,
          path: '/routine-detail',
        ),
      ];
}
