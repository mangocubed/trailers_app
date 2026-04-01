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
          key: ValueKey(state.uri.query),
          queryParams: HomeQueryParams.fromMap(state.uri.queryParameters),
          extraParams: state.extra is HomeExtraParams ? state.extra as HomeExtraParams : null,
        ),
        routes: [
          GoRoute(
            name: routeNameShowTitle,
            path: 'titles/:$keyTitleId',
            builder: (context, state) {
              final id = state.pathParameters[keyTitleId]!;

              return ShowTitleScreen(key: ValueKey(id), id: id);
            },
          ),
          GoRoute(
            name: routeNameShowUser,
            path: 'users/:$keyUsername',
            builder: (context, state) {
              final username = state.pathParameters[keyUsername]!;
              return ShowUserScreen(key: ValueKey(username), username: username);
            },
            routes: [
              GoRoute(
                name: routeNameShowUserBookmarks,
                path: 'bookmarks',
                builder: (context, state) {
                  final username = state.pathParameters[keyUsername]!;

                  return ShowUserBookmarksScreen(
                    key: ValueKey('$username?${state.uri.query}'),
                    username: username,
                    queryParams: UserQueryParams.fromMap(state.uri.queryParameters),
                    extraParams: state.extra as UserExtraParams?,
                  );
                },
                routes: [
                  GoRoute(
                    name: routeNameShowUserBookmarksTitle,
                    path: 'titles/:$keyTitleId',
                    builder: (context, state) {
                      final id = state.pathParameters[keyTitleId]!;

                      return ShowTitleScreen(key: ValueKey(id), id: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                name: routeNameShowUserWatched,
                path: 'watched',
                builder: (context, state) {
                  final username = state.pathParameters[keyUsername]!;
                  return ShowUserWatchedScreen(
                    key: ValueKey('$username?${state.uri.query}'),
                    username: username,
                    queryParams: UserQueryParams.fromMap(state.uri.queryParameters),
                    extraParams: state.extra as UserExtraParams?,
                  );
                },
                routes: [
                  GoRoute(
                    name: routeNameShowUserWatchedTitle,
                    path: 'titles/:$keyTitleId',
                    builder: (context, state) {
                      final id = state.pathParameters[keyTitleId]!;

                      return ShowTitleScreen(key: ValueKey(id), id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
