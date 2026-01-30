import 'package:go_router/go_router.dart';
import 'package:trailers/constants.dart';

import 'screens/home_screen.dart';
import 'screens/register_screen.dart';

extension GoRouterExt on GoRouter {
  static GoRouter setup() => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: routeNameHome,
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(name: routeNameRegister, path: '/register', builder: (context, state) => const RegisterScreen()),
        ],
      ),
    ],
  );
}
