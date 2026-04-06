import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.readOnly = false,
    this.onChanged,
    this.onClear,
    this.onTap,
  });

  final TextEditingController controller;
  final bool autofocus;
  final bool readOnly;
  final Function(String)? onChanged;
  final Function()? onClear;
  final Function()? onTap;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _timer;

  void _onChanged(String text) {
    _timer?.cancel();

    _timer = Timer(Config.searchDebounce, () {
      widget.onChanged?.call(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        constraints: const BoxConstraints(maxHeight: 40),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 16),
        suffixIcon: widget.controller.text.isNotEmpty
            ? InkWell(
                onTap: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                },
                child: const MouseRegion(cursor: SystemMouseCursors.click, child: Icon(Icons.highlight_off_rounded)),
              )
            : const Icon(Icons.search_rounded),
        suffixIconColor: Colors.white,
        hintText: 'Search',
        hintStyle: const TextStyle(fontSize: 16, color: Colors.white54),
      ),
      minLines: 1,
      maxLines: 1,
      style: const TextStyle(fontSize: 16, color: Colors.white),
      onChanged: _onChanged,
      onTap: widget.onTap,
    );
  }
}
