import 'package:flutter/material.dart';

class CenteredLayout extends StatelessWidget {
  const CenteredLayout({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.disableLeading = false,
    this.leading,
  });

  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool disableLeading;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        actions: actions,
        automaticallyImplyLeading: !disableLeading,
        leading: leading,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            child: Center(child: SizedBox(width: 640, child: child)),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
