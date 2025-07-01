import 'package:auto_route/auto_route.dart';
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
          page: RoutineListRoute.page,
          initial: true,
          path: '/',
        ),
        AutoRoute(
          page: RoutineFormRoute.page,
          path: '/routine-form',
        ),
      ];
}
