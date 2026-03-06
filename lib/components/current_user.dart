import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/fragments/user_fragment.graphql.dart';
import '../components/screen_lifecycle.dart';
import '../graphql/queries/current_user.graphql.dart';

class CurrentUser extends StatelessWidget {
  const CurrentUser({super.key, required this.builder});

  final Widget Function(Fragment$UserFragment? user, {Refetch<Query$CurrentUser>? refetch}) builder;

  @override
  Widget build(BuildContext context) {
    return Query$CurrentUser$Widget(
      builder: (result, {fetchMore, refetch}) {
        final user = result.parsedData?.currentUser;

        return ScreenLifecycle(
          onResume: () async {
            if (!result.isLoading) {
              try {
                await refetch?.call();
              } catch (_) {}
            }
          },
          child: builder(user, refetch: refetch),
        );
      },
    );
  }
}
