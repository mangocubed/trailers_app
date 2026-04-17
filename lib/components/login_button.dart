import 'package:flutter/material.dart';

import 'package:toolbox/identity_client.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await IdentityClient.authorize(context);
      },
      icon: const Icon(Icons.login_rounded),
      label: const Text('Login or Register'),
    );
  }
}
