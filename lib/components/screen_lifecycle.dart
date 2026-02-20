import 'package:flutter/material.dart';

import '../router.dart';

class ScreenLifecycle extends StatefulWidget {
  const ScreenLifecycle({super.key, required this.child, this.onResume});

  final Widget child;
  final void Function()? onResume;

  @override
  State<ScreenLifecycle> createState() => _ScreenLifecycleState();
}

class _ScreenLifecycleState extends State<ScreenLifecycle> with WidgetsBindingObserver, RouteAware {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentRoute = ModalRoute.of(context);

    if (currentRoute != null) {
      routeObserver.subscribe(this, currentRoute);
    }
  }

  @override
  void didPush() {
    widget.onResume?.call();
  }

  @override
  void didPopNext() {
    widget.onResume?.call();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onResume?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
