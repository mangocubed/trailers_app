import 'package:flutter/material.dart';

import 'media_type_chip.dart';
import '../graphql/schema.graphql.dart';

class TitleBasicInfo extends StatelessWidget {
  const TitleBasicInfo({
    super.key,
    this.isCentered = true,
    this.releasedOn,
    this.directorName,
    this.runtime,
    required this.mediaType,
    this.extraChips,
  });

  final bool isCentered;
  final DateTime? releasedOn;
  final String? directorName;
  final Duration? runtime;
  final Enum$TitleMediaType mediaType;
  final List<Widget>? extraChips;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rowChildren = [];
    const rowTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white);

    if (releasedOn != null) {
      rowChildren.add(Text(releasedOn!.year.toString(), style: rowTextStyle));
    }

    if (directorName != null) {
      if (rowChildren.isNotEmpty) {
        rowChildren.addAll([const SizedBox(width: 8), const Text('·', style: rowTextStyle), const SizedBox(width: 8)]);
      }

      rowChildren.add(Flexible(child: Text(directorName!, style: rowTextStyle)));
    }

    if (runtime != null) {
      if (rowChildren.isNotEmpty) {
        rowChildren.addAll([const SizedBox(width: 8), const Text('·', style: rowTextStyle), const SizedBox(width: 8)]);
      }

      rowChildren.add(Text('${runtime!.inMinutes} mins', style: rowTextStyle));
    }

    final mediaTypeChip = MediaTypeChip(mediaType: mediaType);
    late Widget chips;

    if (extraChips?.isNotEmpty == true) {
      chips = Row(
        mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [mediaTypeChip, const SizedBox(width: 8), ...extraChips!],
      );
    } else {
      chips = mediaTypeChip;
    }

    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start, children: rowChildren),
        const SizedBox(height: 8),
        chips,
      ],
    );
  }
}
