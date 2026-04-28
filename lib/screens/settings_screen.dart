import 'package:flutter/material.dart';

import 'package:toolbox/identity_client.dart';

import '../components/login_button.dart';

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
            spacing: 16,
            children: [
              SizedBox(
                width: double.infinity,
                child: IdentityClient.hasAccessToken
                    ? OutlinedButton.icon(
                        onPressed: IdentityClient.goToIdentity,
                        icon: const Icon(Icons.manage_accounts_rounded),
                        label: const Text('Account'),
                      )
                    : LoginButton(),
              ),
              IdentityClient.hasAccessToken
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm your action'),
                              content: const Text('Are you sure you want to disconnect your user account?'),
                              actions: [
                                OutlinedButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(), // Closes dialog
                                ),
                                FilledButton(
                                  child: const Text('Confirm'),
                                  onPressed: () async {
                                    await IdentityClient.revoke();
                                  }, // Closes dialog
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Disconnect'),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
