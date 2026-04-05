import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailers/constants.dart';

import '../router.dart';

class ScreenTitle extends StatefulWidget {
  const ScreenTitle({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  State<ScreenTitle> createState() => _ScreenTitleState();
}

class _ScreenTitleState extends State<ScreenTitle> with RouteAware {
  void _setPageTitle() {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: '${widget.title} | Trailers', primaryColor: colorPrimary.toARGB32()),
    );
  }

  @override
  void initState() {
    super.initState();
    _setPageTitle();
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
  void didPopNext() {
    _setPageTitle();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
