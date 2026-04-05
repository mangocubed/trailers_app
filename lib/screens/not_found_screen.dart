import 'package:flutter/material.dart';

import '../components/screen_title.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);

    return ScreenTitle(
      title: 'Page not found',
      child: Scaffold(
        body: Center(child: Text('Page not found', style: textTheme.bodyLarge)),
      ),
    );
  }
}
