import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../graphql/fragments/title_fragment.graphql.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({super.key, required this.title, this.onTap});

  final Fragment$TitleFragment title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          title.posterImageUrl != null
              ? Image.network(
                  title.posterImageUrl.toString(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : const SizedBox(),
          Container(width: double.infinity, height: double.infinity, color: const Color.fromRGBO(72, 64, 65, 0.40)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.name, style: GoogleFonts.blackHanSans(color: const Color(0xFFF3EAF4), fontSize: 16)),
                title.releasedOn?.year != null
                    ? Text(
                        title.releasedOn!.year.toString(),
                        style: const TextStyle(color: Color(0xFFF3EAF4), fontSize: 14),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap),
        ],
      ),
    );
  }
}
