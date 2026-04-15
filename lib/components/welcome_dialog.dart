import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trailers/constants.dart';
import 'package:url_launcher/url_launcher.dart';

TapGestureRecognizer _getTapRecognizer(Uri url) => TapGestureRecognizer()
  ..onTap = () async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    }
  };

Future<dynamic> showWelcomeDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        icon: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset('assets/icon.png', width: 64, height: 64),
          ),
        ),
        title: Text('Welcome to Filmstrip!'),
        content: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💡 Scroll down to check out movies or TV series recommendations, or use the search bar to find something specific.',
            ),
            Text('📢 Note: This application is still on early stage.'),
            Text.rich(
              TextSpan(
                text: 'ℹ️ Please check our ',
                children: [
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: _getTapRecognizer(Uri.parse(urlPrivacy)),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: _getTapRecognizer(Uri.parse(urlTerms)),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
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
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text('Continue'),
          ),
        ],
      );
    },
  );
}
