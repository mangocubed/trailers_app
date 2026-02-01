import 'package:flutter/material.dart';

class AppLifecycle extends StatefulWidget {
  const AppLifecycle({super.key, required this.child, this.onResume, this.onStateChange});

  final Widget child;
  final void Function()? onResume;
  final void Function(AppLifecycleState state)? onStateChange;

  @override
  State<AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends State<AppLifecycle> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.onStateChange?.call(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
