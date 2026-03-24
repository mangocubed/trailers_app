import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/show_title_screen.dart';
import 'screens/show_user_bookmarks_screen.dart';
import 'screens/show_user_screen.dart';
import 'screens/show_user_watched_screen.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

extension GoRouterExt on GoRouter {
  static GoRouter setup() => GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    observers: [routeObserver],
    routes: [
      GoRoute(
        name: routeNameHome,
        path: '/',
        builder: (context, state) => HomeScreen(
          queryParams: HomeQueryParams.fromMap(state.uri.queryParameters),
          extraParams: state.extra as HomeExtraParams?,
        ),
        routes: [
          GoRoute(
            name: routeNameShowTitle,
            path: 'titles/:$keyTitleId',
            builder: (context, state) {
              final id = state.pathParameters[keyTitleId]!;

              return ShowTitleScreen(id: id);
            },
          ),
          GoRoute(
            name: routeNameShowUser,
            path: 'users/:$keyUsername',
            builder: (context, state) {
              final username = state.pathParameters[keyUsername]!;
              return ShowUserScreen(username: username);
            },
            routes: [
              GoRoute(
                name: routeNameShowUserBookmarks,
                path: 'bookmarks',
                builder: (context, state) {
                  final username = state.pathParameters[keyUsername]!;
                  final extra = state.extra as ShowUserBookmarksExtra?;

                  return ShowUserBookmarksScreen(username: username, extra: extra);
                },
              ),
              GoRoute(
                name: routeNameShowUserBookmarksTitle,
                path: 'titles/:$keyTitleId',
                builder: (context, state) {
                  final id = state.pathParameters[keyTitleId]!;

                  return ShowTitleScreen(id: id);
                },
              ),
              GoRoute(
                name: routeNameShowUserWatched,
                path: 'watched',
                builder: (context, state) {
                  final username = state.pathParameters[keyUsername]!;
                  final extra = state.extra as ShowUserWatchedExtra?;

                  return ShowUserWatchedScreen(username: username, extra: extra);
                },
              ),
              GoRoute(
                name: routeNameShowUserWatchedTitle,
                path: 'titles/:$keyTitleId',
                builder: (context, state) {
                  final id = state.pathParameters[keyTitleId]!;

                  return ShowTitleScreen(id: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
