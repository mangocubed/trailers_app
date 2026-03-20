import 'package:flutter/material.dart';

import '../graphql/schema.graphql.dart';
import '../utils.dart';

class MediaTypeChip extends StatelessWidget {
  const MediaTypeChip({super.key, required this.mediaType});

  final Enum$TitleMediaType mediaType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBFCFF)),
      ),
      child: Text(
        mediaType.toJson().capitalize(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDBFCFF)),
      ),
    );
  }
}
