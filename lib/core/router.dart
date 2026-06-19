import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/navigation/main_layout.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/veedu/veedu_screen.dart';
import '../features/makkal/makkal_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/awards/awards_screen.dart';
import '../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainLayout(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/veedu',
          builder: (BuildContext context, GoRouterState state) => const VeeduScreen(),
        ),
        GoRoute(
          path: '/makkal',
          builder: (BuildContext context, GoRouterState state) => const MakkalScreen(),
        ),
        GoRoute(
          path: '/booking',
          builder: (BuildContext context, GoRouterState state) => const BookingScreen(),
        ),
        GoRoute(
          path: '/awards',
          builder: (BuildContext context, GoRouterState state) => const AwardsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
