import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../components/filters_row.dart';
import '../components/search_dialog.dart';
import '../components/search_field.dart';
import '../graphql/schema.graphql.dart';
import '../components/titles_filter_dialog.dart';
import '../components/sentitive_page_view.dart';
import '../components/user_button.dart';
import '../constants.dart';
import '../graphql/queries/titles.graphql.dart';
import 'show_video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.queryParams, this.extraParams});

  final HomeQueryParams? queryParams;
  final HomeExtraParams? extraParams;

  String? get query => queryParams?.query;
  Enum$TitleMediaType? get mediaType => queryParams?.mediaType;
  List<String>? get genreIds => queryParams?.genreIds;
  List<String>? get watchProviderIds => queryParams?.watchProviderIds;
  String? get countryCode => queryParams?.countryCode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _pageController;
  final _queryController = TextEditingController();

  int get _currentPage => _pageController?.page?.round() ?? 0;

  bool get _hasFilters => widget.queryParams?.hasFilters == true;

  bool get _hasQuery => widget.queryParams?.hasQuery == true;

  Widget _getTitles() {
    final textTheme = TextTheme.of(context);

    return Query$Titles$Widget(
      options: Options$Query$Titles(
        fetchPolicy: !_hasFilters && !_hasQuery ? FetchPolicy.noCache : null,
        typedOptimisticResult: widget.extraParams?.parsedData,
        variables: Variables$Query$Titles(
          first: widget.extraParams?.parsedData?.titles.nodes.length ?? 12,
          query: widget.query,
          mediaType: widget.mediaType,
          genreIds: widget.genreIds,
          watchProviderIds: widget.watchProviderIds,
          countryCode: widget.countryCode,
          includeViewed: _hasFilters || _hasQuery,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titles = result.parsedData?.titles;

        _pageController ??= PageController(initialPage: widget.extraParams?.page ?? 0);

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
          controller: _pageController!,
          onPageChanged: (int page) {
            setState(() {});

            if (result.isLoading || titles!.nodes.length > page + 5) {
              return;
            }

            fetchMore?.call(
              FetchMoreOptions$Query$Titles(
                variables: Variables$Query$Titles(
                  after: titles.pageInfo.endCursor,
                  query: widget.query,
                  mediaType: widget.mediaType,
                  genreIds: widget.genreIds,
                  watchProviderIds: widget.watchProviderIds,
                  countryCode: widget.countryCode,
                  includeViewed: _hasFilters || _hasQuery,
                ),
                updateQuery: (previousResultData, fetchMoreResultData) {
                  if (fetchMoreResultData == null || fetchMoreResultData['titles']['nodes'].length == 0) {
                    return previousResultData;
                  }

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
              countryCode: widget.countryCode,
              onSeeMore: () {
                context.goNamed(
                  routeNameShowTitle,
                  pathParameters: {keyTitleId: title.id},
                  queryParameters: widget.queryParams?.toMap() ?? {},
                );
              },
            );
          },
          itemCount: result.parsedData?.titles.nodes.length,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _queryController.text = widget.query ?? '';
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      _queryController.text = widget.query ?? '';
    }

    if (widget.extraParams?.page != null && widget.extraParams?.page != _pageController?.page) {
      _pageController?.jumpToPage(widget.extraParams?.page ?? 0);
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: SearchField(
          controller: _queryController,
          readOnly: true,
          onTap: () {
            SearchDialog(context, queryParams: widget.queryParams);
          },
          onClear: () {
            final queryParams = widget.queryParams!;

            queryParams.query = null;

            context.goNamed(routeNameHome, queryParameters: queryParams.toMap());
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton.outlined(
              isSelected: _hasFilters,
              icon: SvgPicture.asset(
                'assets/adjust.svg',
                colorFilter: _hasFilters ? ColorFilter.mode(Colors.black, BlendMode.srcIn) : null,
              ),
              onPressed: () {
                TitlesFilterDialog(context, queryParams: widget.queryParams);
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(right: 12), child: UserButton()),
        ],
      ),
      body: Stack(
        children: [
          _getTitles(),
          SafeArea(child: FiltersRow(queryParams: widget.queryParams)),
        ],
      ),
    );
  }
}

class HomeQueryParams {
  HomeQueryParams({this.query, this.mediaType, this.genreIds, this.watchProviderIds, this.countryCode});

  String? query;
  Enum$TitleMediaType? mediaType;
  final List<String>? genreIds;
  final List<String>? watchProviderIds;
  final String? countryCode;

  bool get hasQuery => query != null && query!.length > 1;
  bool get hasFilters => mediaType != null || genreIds != null || watchProviderIds != null;

  static HomeQueryParams fromMap(Map<String, String> value) {
    final String? query = value[keyQuery];
    final String? mediaTypeStr = value[keyMediaType];
    final genreIds = value[keyGenreIds]?.split(',');
    final watchProviderIds = value[keyWatchProviderIds]?.split(',');
    final countryCode = value[keyCountryCode];

    Enum$TitleMediaType? mediaType;

    if (mediaTypeStr != null) {
      mediaType = Enum$TitleMediaType.fromJson(mediaTypeStr);
    }

    return HomeQueryParams(
      query: query,
      mediaType: mediaType,
      genreIds: genreIds,
      watchProviderIds: watchProviderIds,
      countryCode: countryCode,
    );
  }

  Map<String, String> toMap() {
    final Map<String, String> queryParams = {};

    if (hasQuery) {
      queryParams[keyQuery] = query!;
    }

    if (mediaType != null) {
      queryParams[keyMediaType] = mediaType!.toJson();
    }

    if (genreIds != null && genreIds!.isNotEmpty) {
      queryParams[keyGenreIds] = genreIds!.join(',');
    }

    if (watchProviderIds != null && watchProviderIds!.isNotEmpty) {
      queryParams[keyWatchProviderIds] = watchProviderIds!.join(',');
    }

    if (countryCode != null && countryCode!.isNotEmpty) {
      queryParams[keyCountryCode] = countryCode!;
    }

    return queryParams;
  }
}

class HomeExtraParams {
  HomeExtraParams({required this.parsedData, required this.page});

  final Query$Titles? parsedData;
  final int page;
}
