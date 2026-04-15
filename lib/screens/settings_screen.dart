import 'package:flutter/material.dart';

import '../components/current_user.dart';
import '../identity_client.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          width: 640,
          child: Column(
            spacing: 8,
            children: [
              SizedBox(
                width: double.infinity,
                child: CurrentUser(
                  builder: (user, {refetch}) {
                    if (user != null) {
                      return OutlinedButton.icon(
                        onPressed: IdentityClient.goToIdentity,
                        icon: const Icon(Icons.manage_accounts_rounded),
                        label: const Text('Account'),
                      );
                    } else {
                      return OutlinedButton.icon(
                        onPressed: () => IdentityClient.authorize(context),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Login or Register'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
