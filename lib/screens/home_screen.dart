import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/queries/genres.graphql.dart';
import '../graphql/schema.graphql.dart';
import '../components/titles_filter_dialog.dart';
import '../components/sentitive_page_view.dart';
import '../components/user_button.dart';
import '../constants.dart';
import '../graphql/queries/titles.graphql.dart';
import '../utils.dart';
import 'show_video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.mediaType, this.genresIds});

  final Enum$TitleMediaType? mediaType;
  final List<String>? genresIds;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  bool _resultsChanged = false;

  int get _currentPage => _pageController.page?.round() ?? 0;

  bool get _isFiltered => widget.mediaType != null || widget.genresIds != null;

  Widget _getFilters() {
    if (!_isFiltered) {
      return const SizedBox();
    }

    final List<Widget> filters = [];

    if (widget.mediaType != null) {
      filters.add(
        FilterChip(
          label: Text(widget.mediaType!.toJson().capitalize()),
          showCheckmark: false,
          selected: true,
          onSelected: (value) {
            context.goNamed(routeNameHome, queryParameters: getTitlesFilterQueryParams(genresIds: widget.genresIds));
          },
          onDeleted: () {
            context.goNamed(routeNameHome, queryParameters: getTitlesFilterQueryParams(genresIds: widget.genresIds));
          },
        ),
      );
    }

    if (widget.genresIds != null && widget.genresIds!.isNotEmpty) {
      filters.add(
        Query$Genres$Widget(
          options: Options$Query$Genres(variables: Variables$Query$Genres(ids: widget.genresIds!)),
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
                          onSelected: (value) {
                            context.goNamed(
                              routeNameHome,
                              queryParameters: getTitlesFilterQueryParams(
                                mediaType: widget.mediaType,
                                genresIds: widget.genresIds?.where((id) => id != genre.id).toList(),
                              ),
                            );
                          },

                          onDeleted: () {
                            context.goNamed(
                              routeNameHome,
                              queryParameters: getTitlesFilterQueryParams(
                                mediaType: widget.mediaType,
                                genresIds: widget.genresIds?.where((id) => id != genre.id).toList(),
                              ),
                            );
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

  Widget _getRecommendedTitles() {
    final textTheme = TextTheme.of(context);

    return Query$Titles$Widget(
      options: Options$Query$Titles(
        fetchPolicy: FetchPolicy.noCache,
        variables: Variables$Query$Titles(
          mediaType: widget.mediaType,
          genreIds: widget.genresIds,
          includeViewed: _isFiltered,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titles = result.parsedData?.titles;

        if (result.parsedData == null && result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (titles?.nodes.isNotEmpty != true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 14,
              children: [
                Text(
                  titles == null ? 'Something went wrong 🫠' : 'We couldn\'t find anything for you 👀',
                  style: textTheme.bodyLarge,
                ),
                OutlinedButton(
                  onPressed: () {
                    refetch?.call();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SensitivePageView(
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {});

            if (result.isLoading || titles!.nodes.length > page + 5) {
              return;
            }

            fetchMore?.call(
              FetchMoreOptions$Query$Titles(
                variables: Variables$Query$Titles(
                  after: _resultsChanged ? null : titles.pageInfo.endCursor,
                  mediaType: widget.mediaType,
                  genreIds: widget.genresIds,
                  includeViewed: _isFiltered,
                ),
                updateQuery: (previousResultData, fetchMoreResultData) {
                  if (fetchMoreResultData == null || fetchMoreResultData['titles']['nodes'].length == 0) {
                    return previousResultData;
                  }

                  _resultsChanged = false;

                  fetchMoreResultData['titles']['nodes'] = [
                    ...previousResultData?['titles']['nodes'],
                    ...fetchMoreResultData['titles']['nodes']
                        .where(
                          (node) =>
                              previousResultData?['titles']['nodes'].map((node1) => node1['id']).contains(node['id']) !=
                              true,
                        )
                        .toList(),
                  ];

                  fetchMoreResultData['titles']['pageInfo']['startCursor'] =
                      previousResultData?['titles']['pageInfo']['startCursor'];

                  return fetchMoreResultData;
                },
              ),
            );
          },

          itemBuilder: (context, index) {
            final title = titles!.nodes[index];

            return ShowVideoScreen(
              index: index,
              currentPage: _currentPage,
              title: title,
              onUpdated: () => _resultsChanged = true,
            );
          },
          itemCount: result.parsedData?.titles.nodes.length,
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: OutlinedButton(
          onPressed: () => context.goNamed(routeNameSearch),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Search', style: const TextStyle(fontSize: 16, color: Color(0x88FFFFFF))),
              const Icon(Icons.search_rounded, color: Colors.white),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton.outlined(
              isSelected: _isFiltered,
              icon: SvgPicture.asset(
                'assets/adjust.svg',
                colorFilter: _isFiltered ? ColorFilter.mode(Colors.black, BlendMode.srcIn) : null,
              ),
              onPressed: () async {
                TitlesFilterDialog(context, mediaType: widget.mediaType, genresIds: widget.genresIds);
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(right: 12), child: UserButton()),
        ],
      ),
      body: Stack(
        children: [
          _getRecommendedTitles(),
          SafeArea(child: _getFilters()),
        ],
      ),
    );
  }
}
