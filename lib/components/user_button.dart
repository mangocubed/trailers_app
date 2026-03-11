import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trailers/identity_client.dart';

import '../constants.dart';
import 'current_user.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CurrentUser(
      builder: (user, {refetch}) {
        if (user != null) {
          return IconButton(
            onPressed: () =>
                context.goNamed(routeNameShowUser, pathParameters: {keyUsername: user.identityUser.username}),
            icon: CircleAvatar(child: Text(user.identityUser.initials)),
          );
        } else {
          return IconButton(
            onPressed: () async {
              await IdentityClient.authorize(context);

              await refetch?.call();
            },
            icon: const Icon(Icons.login_rounded, color: Colors.white),
          );
        }
      },
    );
  }
}
