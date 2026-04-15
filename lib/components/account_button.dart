import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trailers/graphql/fragments/user_fragment.graphql.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../identity_client.dart';
import 'current_user.dart';

class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  void _showAccountBottomSheet(BuildContext context, {Fragment$UserFragment? user}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: 480,
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              user != null
                  ? Column(
                      spacing: 8,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 32,
                            child: Text(user.identityUser.initials, style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        Text(
                          '@${user.identityUser.username}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed(
                              routeNameShowUser,
                              pathParameters: {keyUsername: user.identityUser.username},
                            ),
                            icon: const Icon(Icons.person_rounded),
                            label: const Text('Profile'),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => IdentityClient.authorize(context),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Login or Register'),
                      ),
                    ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.goNamed(routeNameSettings),
                  icon: Icon(Icons.settings_rounded),
                  label: const Text('Settings'),
                ),
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse(urlPrivacy);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      }
                    },
                    child: const Text('Privacy Policy'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse(urlTerms);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      }
                    },
                    child: const Text('Terms of Service'),
                  ),
                ],
              ),
              FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: Text(
                        'Version ${snapshot.data!.version}',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    );
                  }

                  return SizedBox();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurrentUser(
      builder: (user, {refetch}) {
        if (user != null) {
          return IconButton(
            onPressed: () => _showAccountBottomSheet(context, user: user),
            icon: CircleAvatar(child: Text(user.identityUser.initials)),
          );
        } else {
          return IconButton.outlined(
            onPressed: () => _showAccountBottomSheet(context),
            icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
          );
        }
      },
    );
  }
}
