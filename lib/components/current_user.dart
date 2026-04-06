import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/fragments/user_fragment.graphql.dart';
import '../graphql/queries/current_user.graphql.dart';
import '../router.dart';

class CurrentUser extends StatefulWidget {
  const CurrentUser({super.key, required this.builder});

  final Widget Function(Fragment$UserFragment? user, {Refetch<Query$CurrentUser>? refetch}) builder;

  @override
  State<CurrentUser> createState() => _CurrentUserState();
}

class _CurrentUserState extends State<CurrentUser> with RouteAware {
  bool _isLoading = false;
  Refetch<Query$CurrentUser>? _refetch;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentRoute = ModalRoute.of(context);

    if (currentRoute != null) {
      routeObserver.subscribe(this, currentRoute);
    }
  }

  @override
  void didPopNext() {
    if (!_isLoading) {
      try {
        _refetch?.call();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Query$CurrentUser$Widget(
      builder: (result, {fetchMore, refetch}) {
        final user = result.parsedData?.currentUser;

        _refetch ??= refetch;
        _isLoading = result.isLoading;

        return widget.builder(user, refetch: refetch);
      },
    );
  }
}
