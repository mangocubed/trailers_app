import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:trailers/constants.dart';
import 'package:trailers/session.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/register_screen.dart';
import 'screens/show_title_screen.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

Future<String?> _requireAuthentication(BuildContext context, GoRouterState state) async {
  if (!await Session.isAuthenticated()) {
    return '/login';
  }

  return null;
}

Future<String?> _requireNoAuthentication(BuildContext context, GoRouterState state) async {
  if (await Session.isAuthenticated()) {
    return '/';
  }

  return null;
}

extension GoRouterExt on GoRouter {
  static GoRouter setup() => GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    observers: [routeObserver],
    routes: [
      GoRoute(
        name: routeNameHome,
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            name: routeNameLogin,
            path: 'login',
            redirect: _requireNoAuthentication,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            name: routeNameRegister,
            path: 'register',
            redirect: _requireNoAuthentication,
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            name: routeNameShowTitle,
            path: 'titles/:$keyTitleId',
            builder: (context, state) {
              final id = state.pathParameters[keyTitleId]!;
              final videoId = state.uri.queryParameters[keyVideoId];

              return ShowTitleScreen(id: id, videoId: videoId);
            },
          ),
        ],
      ),
    ],
  );
}
