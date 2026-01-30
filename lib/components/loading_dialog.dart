import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingDialog {
  LoadingDialog(this.context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            alignment: Alignment.center,
            width: 72,
            height: 72,
            child: const CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  final BuildContext context;

  void close() {
    context.pop();
  }
}
