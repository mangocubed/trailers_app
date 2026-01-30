import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.onSaved,
    this.onTap,
    this.onChanged,
    this.initialValue,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.prefixIcon,
    this.suffixIcon,
    this.required = false,
    this.enabled,
    this.readOnly = false,
    this.obscureText = false,
    this.mouseCursor,
    this.validator,
    this.errorText,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final void Function(String?)? onChanged;
  final String? initialValue;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool required;
  final bool? enabled;
  final bool readOnly;
  final bool obscureText;
  final MouseCursor? mouseCursor;
  final String? Function(String?)? validator;
  final String? errorText;

  String? _validator(BuildContext context, String? value) {
    if (required && value?.trim().isNotEmpty != true) {
      return 'Can\'t be blank';
    }

    return validator?.call(value);
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(),
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
    ),
    keyboardType: keyboardType,
    minLines: minLines ?? (keyboardType == TextInputType.multiline ? 2 : null),
    maxLines: maxLines ?? 1,
    validator: (value) => _validator(context, value),
    onSaved: onSaved,
    onTap: onTap,
    onChanged: onChanged,
    initialValue: initialValue,
    enabled: enabled,
    readOnly: readOnly,
    obscureText: obscureText,
    mouseCursor: mouseCursor,
  );
}
