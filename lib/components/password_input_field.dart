import 'package:flutter/material.dart';

import './text_input_field.dart';

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    required this.onSaved,
    this.required = false,
    this.labelText,
    this.errorText,
    this.prefixIcon,
  });

  final String? labelText;
  final Function(String?)? onSaved;
  final bool required;
  final String? errorText;
  final Widget? prefixIcon;

  @override
  createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _passwordIsHidden = true;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordIsHidden = !_passwordIsHidden;
    });
  }

  @override
  Widget build(BuildContext context) => TextInputField(
    labelText: widget.labelText ?? 'Password',
    prefixIcon: widget.prefixIcon,
    suffixIcon: GestureDetector(
      onTap: _togglePasswordVisibility,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Icon(_passwordIsHidden ? Icons.visibility : Icons.visibility_off),
      ),
    ),
    errorText: widget.errorText,
    keyboardType: TextInputType.visiblePassword,
    maxLines: 1,
    obscureText: _passwordIsHidden,
    onSaved: widget.onSaved,
    required: widget.required,
  );
}
