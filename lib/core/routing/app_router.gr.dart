// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    RoutineFormRoute.name: (routeData) {
      final args = routeData.argsAs<RoutineFormRouteArgs>(
          orElse: () => const RoutineFormRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RoutineFormScreen(
          key: args.key,
          routine: args.routine,
        ),
      );
    },
    RoutineListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RoutineListScreen(),
      );
    },
  };
}

/// generated route for
/// [RoutineFormScreen]
class RoutineFormRoute extends PageRouteInfo<RoutineFormRouteArgs> {
  RoutineFormRoute({
    Key? key,
    Routine? routine,
    List<PageRouteInfo>? children,
  }) : super(
          RoutineFormRoute.name,
          args: RoutineFormRouteArgs(
            key: key,
            routine: routine,
          ),
          initialChildren: children,
        );

  static const String name = 'RoutineFormRoute';

  static const PageInfo<RoutineFormRouteArgs> page =
      PageInfo<RoutineFormRouteArgs>(name);
}

class RoutineFormRouteArgs {
  const RoutineFormRouteArgs({
    this.key,
    this.routine,
  });

  final Key? key;

  final Routine? routine;

  @override
  String toString() {
    return 'RoutineFormRouteArgs{key: $key, routine: $routine}';
  }
}

/// generated route for
/// [RoutineListScreen]
class RoutineListRoute extends PageRouteInfo<void> {
  const RoutineListRoute({List<PageRouteInfo>? children})
      : super(
          RoutineListRoute.name,
          initialChildren: children,
        );

  static const String name = 'RoutineListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
