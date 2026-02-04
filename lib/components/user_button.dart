import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trailers/datetime.dart';

import '../components/screen_lifecycle.dart';
import '../constants.dart';
import '../graphql/queries/current_user.graphql.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Query$CurrentUser$Widget(
      builder: (result, {fetchMore, refetch}) {
        final currentUser = result.parsedData?.currentUser;

        late Widget child;

        if (currentUser != null) {
          child = CircleAvatar(child: Text(currentUser.initials));
        } else {
          child = IconButton(
            onPressed: () => context.goNamed(routeNameLogin),
            icon: const Icon(Icons.login_rounded, color: Colors.white),
          );
        }

        return ScreenLifecycle(
          onResume: () async {
            if (!result.isLoading && result.timestamp.elapsed().inSeconds >= 5) {
              await refetch?.call();
            }
          },
          child: child,
        );
      },
    );
  }
}
