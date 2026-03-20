import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';
import '../graphql/schema.graphql.dart';
import '../utils.dart';

class TitlesFilterDialog {
  TitlesFilterDialog(BuildContext context, {Enum$TitleMediaType? mediaType}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      fullscreenDialog: true,
      builder: (context) {
        return Dialog.fullscreen(child: _TitlesFilterDialogBody(mediaType));
      },
    );
  }
}

class _TitlesFilterDialogBody extends StatefulWidget {
  const _TitlesFilterDialogBody(this.mediaType);

  final Enum$TitleMediaType? mediaType;

  @override
  State<_TitlesFilterDialogBody> createState() => _TitlesFilterDialogBodyState();
}

class _TitlesFilterDialogBodyState extends State<_TitlesFilterDialogBody> {
  Enum$TitleMediaType? _mediaType;

  @override
  void initState() {
    super.initState();

    _mediaType = widget.mediaType;
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final Map<String, String> queryParams = {};

                  if (_mediaType != null) {
                    queryParams[keyMediaType] = _mediaType!.toJson();
                  }

                  context.goNamed(routeNameHome, queryParameters: queryParams);
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
