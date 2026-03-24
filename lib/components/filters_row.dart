import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';
import '../graphql/queries/genres.graphql.dart';
import '../graphql/queries/watch_providers.graphql.dart';
import '../screens/home_screen.dart';
import '../utils.dart';

class FiltersRow extends StatelessWidget {
  const FiltersRow({super.key, this.queryParams});

  final HomeQueryParams? queryParams;

  Widget _getFilters(BuildContext context) {
    if (queryParams?.hasFilters != true) {
      return const SizedBox();
    }

    final List<Widget> filters = [];

    if (queryParams!.mediaType != null) {
      filters.add(
        FilterChip(
          label: Text(queryParams!.mediaType!.toJson().capitalize()),
          showCheckmark: false,
          selected: true,
          onSelected: (value) {},
          onDeleted: () {
            queryParams!.mediaType = null;

            context.goNamed(routeNameHome, queryParameters: queryParams!.toMap());
          },
        ),
      );
    }

    if (queryParams!.genreIds != null && queryParams!.genreIds!.isNotEmpty) {
      filters.add(
        Query$Genres$Widget(
          options: Options$Query$Genres(variables: Variables$Query$Genres(ids: queryParams!.genreIds!)),
          builder: (result, {fetchMore, refetch}) {
            final genres = result.parsedData?.genres.nodes;

            return Row(
              spacing: 8,
              children:
                  genres
                      ?.map(
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
                          selected: true,
                          onSelected: (value) {},
                          onDeleted: () {
                            queryParams!.genreIds?.remove(genre.id);

                            context.goNamed(routeNameHome, queryParameters: queryParams!.toMap());
                          },
                        ),
                      )
                      .toList() ??
                  [],
            );
          },
        ),
      );
    }

    if (queryParams!.watchProviderIds != null && queryParams!.watchProviderIds!.isNotEmpty) {
      filters.add(
        Query$WatchProviders$Widget(
          options: Options$Query$WatchProviders(
            variables: Variables$Query$WatchProviders(
              ids: queryParams!.watchProviderIds,
              countryCode: queryParams!.countryCode,
            ),
          ),
          builder: (result, {fetchMore, refetch}) {
            final watchProviders = result.parsedData?.watchProviders.nodes;

            return Row(
              spacing: 8,
              children:
                  watchProviders
                      ?.map(
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
                          selected: true,
                          onSelected: (value) {},
                          onDeleted: () {
                            queryParams!.watchProviderIds?.remove(watchProvider.id);

                            context.goNamed(routeNameHome, queryParameters: queryParams!.toMap());
                          },
                        ),
                      )
                      .toList() ??
                  [],
            );
          },
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 14),
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.max, spacing: 8, children: filters),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getFilters(context);
  }
}
