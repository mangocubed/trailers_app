import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/fragments/user_fragment.graphql.dart';
import '../graphql/queries/current_user.graphql.dart';

class CurrentUser extends StatefulWidget {
  const CurrentUser({super.key, required this.builder});

  final Widget Function(Fragment$UserFragment? user, {Refetch<Query$CurrentUser>? refetch}) builder;

  @override
  State<CurrentUser> createState() => _CurrentUserState();
}

class _CurrentUserState extends State<CurrentUser> {
  Refetch<Query$CurrentUser>? _refetch;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Query$CurrentUser$Widget(
      builder: (result, {fetchMore, refetch}) {
        final user = result.parsedData?.currentUser;

        _refetch ??= refetch;

        return widget.builder(user, refetch: refetch);
      },
    );
  }
}
