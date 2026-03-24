import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:trailers/screens/home_screen.dart';

import '../constants.dart';
import '../graphql/schema.graphql.dart';
import '../graphql/queries/genres.graphql.dart';
import '../graphql/queries/watch_providers.graphql.dart';
import '../utils.dart';
import 'current_user.dart';

class TitlesFilterDialog {
  TitlesFilterDialog(BuildContext context, {HomeQueryParams? queryParams}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      fullscreenDialog: true,
      builder: (context) {
        return Dialog.fullscreen(child: _TitlesFilterDialogBody(queryParams: queryParams));
      },
    );
  }
}

class _TitlesFilterDialogBody extends StatefulWidget {
  const _TitlesFilterDialogBody({this.queryParams});

  final HomeQueryParams? queryParams;

  Enum$TitleMediaType? get mediaType => queryParams?.mediaType;
  List<String>? get genreIds => queryParams?.genreIds;
  List<String>? get watchProviderIds => queryParams?.watchProviderIds;
  String? get countryCode => queryParams?.countryCode;

  @override
  State<_TitlesFilterDialogBody> createState() => _TitlesFilterDialogBodyState();
}

class _TitlesFilterDialogBodyState extends State<_TitlesFilterDialogBody> {
  Enum$TitleMediaType? _mediaType;
  List<String>? _genreIds;
  List<String>? _watchProviderIds;
  String? _countryCode;

  Country get _country => Country.parse(_countryCode ?? 'US');

  Widget _getWatchProviders() {
    final textTheme = TextTheme.of(context);
    return CurrentUser(
      builder: (user, {refetch}) {
        _countryCode ??= user?.identityUser.countryCode;

        return Query$WatchProviders$Widget(
          options: Options$Query$WatchProviders(
            variables: Variables$Query$WatchProviders(countryCode: _country.countryCode),
          ),
          builder: (result, {refetch, fetchMore}) {
            final nodes = result.parsedData?.watchProviders.nodes;
            final pageInfo = result.parsedData?.watchProviders.pageInfo;
            late final Widget watchProviders;

            if (nodes != null && nodes.isNotEmpty) {
              watchProviders = Column(
                spacing: 8,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: nodes
                        .map(
                          (watchProvider) => FilterChip(
                            avatar: watchProvider.logoImageUrl != null
                                ? CircleAvatar(backgroundImage: NetworkImage(watchProvider.logoImageUrl!.toString()))
                                : null,
                            label: Text(watchProvider.name),
                            labelStyle: GoogleFonts.amiko(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: WidgetStateColor.resolveWith((state) {
                                return state.contains(WidgetState.selected) ? Colors.black : Colors.lightBlue;
                              }),
                            ),
                            side: BorderSide(color: Colors.lightBlue),
                            selectedColor: Colors.lightBlue,
                            selected: _watchProviderIds?.contains(watchProvider.id) ?? false,
                            onSelected: (value) {
                              _watchProviderIds ??= [];

                              setState(() {
                                if (value) {
                                  if (!_watchProviderIds!.contains(watchProvider.id)) {
                                    _watchProviderIds?.add(watchProvider.id);
                                  }
                                } else {
                                  _watchProviderIds?.remove(watchProvider.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  pageInfo?.hasNextPage == true
                      ? Center(
                          child: result.isLoading
                              ? CircularProgressIndicator()
                              : TextButton(
                                  onPressed: () {
                                    fetchMore?.call(
                                      FetchMoreOptions$Query$WatchProviders(
                                        variables: Variables$Query$WatchProviders(
                                          countryCode: _country.countryCode,
                                          after: pageInfo?.endCursor,
                                        ),
                                        updateQuery: (previousResult, fetchMoreResult) {
                                          if (fetchMoreResult == null ||
                                              fetchMoreResult['watchProviders']['nodes'].length == 0) {
                                            return previousResult;
                                          }

                                          fetchMoreResult['watchProviders']['nodes'] = [
                                            ...previousResult?['watchProviders']['nodes'],
                                            ...fetchMoreResult['watchProviders']['nodes']
                                                .where(
                                                  (node) =>
                                                      previousResult?['watchProviders']['nodes']
                                                          .map((node1) => node1['id'])
                                                          .contains(node['id']) !=
                                                      true,
                                                )
                                                .toList(),
                                          ];

                                          return fetchMoreResult;
                                        },
                                      ),
                                    );
                                  },
                                  child: Text('Load more'),
                                ),
                        )
                      : SizedBox(),
                ],
              );
            } else if (result.isLoading) {
              watchProviders = const Center(child: CircularProgressIndicator());
            } else {
              watchProviders = Center(child: Text('No services found in this country 🙁', style: textTheme.bodyLarge));
            }

            return Column(
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avalable in...',
                      style: GoogleFonts.blackHanSans(
                        color: const Color(0xFFF3EAF4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showCountryPicker(
                        context: context,
                        onSelect: (value) {
                          setState(() {
                            _countryCode = value.countryCode;
                          });
                        },
                      ),
                      icon: Row(
                        children: [
                          Text(_country.flagEmoji, style: const TextStyle(fontSize: 20)),
                          const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                watchProviders,
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _mediaType = widget.mediaType;
    _genreIds = widget.genreIds;
    _watchProviderIds = widget.watchProviderIds;
    _countryCode = widget.countryCode;
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              selected: _genreIds?.contains(genre.id) ?? false,
                              onSelected: (value) {
                                _genreIds ??= [];

                                setState(() {
                                  if (value) {
                                    if (!_genreIds!.contains(genre.id)) {
                                      _genreIds?.add(genre.id);
                                    }
                                  } else {
                                    _genreIds?.remove(genre.id);
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
            _getWatchProviders(),
            SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.goNamed(
                    routeNameHome,
                    queryParameters: HomeQueryParams(
                      query: widget.queryParams?.query,
                      mediaType: _mediaType,
                      genreIds: _genreIds,
                      watchProviderIds: _watchProviderIds,
                      countryCode: _countryCode,
                    ).toMap(),
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
