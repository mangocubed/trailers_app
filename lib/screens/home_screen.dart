import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: IconButton(
          onPressed: () => context.goNamed(routeNameRegister),
          icon: Icon(Icons.login_rounded),
        ),
      ),
    );
  }
}
