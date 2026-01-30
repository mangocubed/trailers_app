import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, this.labelText, this.isLoading = false, required this.onPressed});

  final String? labelText;
  final bool isLoading;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(onPressed: (isLoading ? null : onPressed), child: Text(labelText ?? 'Submit')),
  );
}
