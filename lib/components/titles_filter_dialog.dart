import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';
import '../graphql/schema.graphql.dart';
import '../graphql/queries/genres.graphql.dart';
import '../utils.dart';

class TitlesFilterDialog {
  TitlesFilterDialog(BuildContext context, {Enum$TitleMediaType? mediaType, List<String>? genresIds}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      fullscreenDialog: true,
      builder: (context) {
        return Dialog.fullscreen(child: _TitlesFilterDialogBody(mediaType, genresIds));
      },
    );
  }
}

class _TitlesFilterDialogBody extends StatefulWidget {
  const _TitlesFilterDialogBody(this.mediaType, this.genresIds);

  final Enum$TitleMediaType? mediaType;
  final List<String>? genresIds;

  @override
  State<_TitlesFilterDialogBody> createState() => _TitlesFilterDialogBodyState();
}

class _TitlesFilterDialogBodyState extends State<_TitlesFilterDialogBody> {
  Enum$TitleMediaType? _mediaType;
  List<String>? _genresIds;

  @override
  void initState() {
    super.initState();

    _mediaType = widget.mediaType;
    _genresIds = widget.genresIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [Padding(padding: EdgeInsets.only(right: 12), child: CloseButton())],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 14, bottom: 32, left: 14),
        child: Column(
          spacing: 14,
          children: [
            Text(
              'Looking for a...',
              style: GoogleFonts.blackHanSans(
                color: const Color(0xFFF3EAF4),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              spacing: 8,
              children: Enum$TitleMediaType.values
                  .where((mediaType) => mediaType != Enum$TitleMediaType.$unknown)
                  .map(
                    (mediaType) => ChoiceChip(
                      label: Text(mediaType.toJson().capitalize()),
                      selected: _mediaType == mediaType,
                      onSelected: (value) {
                        setState(() {
                          _mediaType = value ? mediaType : null;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 14),
            Query$Genres$Widget(
              builder: (result, {refetch, fetchMore}) {
                final genres = result.parsedData?.genres.nodes;

                if (genres == null || genres.isEmpty) {
                  if (result.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const SizedBox();
                  }
                }

                return Column(
                  spacing: 8,
                  children: [
                    Text(
                      'Something with...',
                      style: GoogleFonts.blackHanSans(
                        color: const Color(0xFFF3EAF4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genres
                          .map(
                            (genre) => FilterChip(
                              label: Text(genre.name),
                              labelStyle: GoogleFonts.amiko(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: WidgetStateColor.resolveWith((state) {
                                  return state.contains(WidgetState.selected) ? Colors.black : Color(0xFFC3D350);
                                }),
                              ),
                              side: BorderSide(color: Color(0xFFC3D350)),
                              selectedColor: Color(0xFFC3D350),
                              selected: _genresIds?.contains(genre.id) ?? false,
                              onSelected: (value) {
                                _genresIds ??= [];

                                setState(() {
                                  if (value) {
                                    if (!_genresIds!.contains(genre.id)) {
                                      _genresIds?.add(genre.id);
                                    }
                                  } else {
                                    _genresIds?.remove(genre.id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.goNamed(
                    routeNameHome,
                    queryParameters: getTitlesFilterQueryParams(mediaType: _mediaType, genresIds: _genresIds),
                  );
                  context.pop();
                },
                child: Text('APPLY FILTERS'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _mediaType = null;
                  });
                },
                child: Text('RESET'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('CANCEL'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
