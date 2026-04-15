import 'package:flutter/material.dart';

import '../components/current_user.dart';
import '../identity_client.dart';
import '../settings.dart';

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
              SizedBox(width: double.infinity, child: _AutoplayVideosButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoplayVideosButton extends StatefulWidget {
  const _AutoplayVideosButton();

  @override
  State<_AutoplayVideosButton> createState() => _AutoplayVideosButtonState();
}

class _AutoplayVideosButtonState extends State<_AutoplayVideosButton> {
  void _showAutoplayBottomSheet(AutoplayVideos currentValue) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        width: 480,
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: AutoplayVideos.values
              .map(
                (value) => SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: value == currentValue ? const Icon(Icons.check_rounded) : null,
                    onPressed: () {
                      Settings.setAutoplayVideos(value);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    label: Text(value.toText()),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Settings.getAutoplayVideos(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return OutlinedButton.icon(
            onPressed: () => _showAutoplayBottomSheet(snapshot.data!),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12,
              children: [
                Text('Autoplay Videos'),
                Text('(${snapshot.data!.toText()})', style: TextStyle(fontSize: 11)),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
