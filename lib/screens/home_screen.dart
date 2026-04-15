import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../components/account_button.dart';
import '../components/filters_row.dart';
import '../components/screen_title.dart';
import '../components/search_dialog.dart';
import '../components/search_field.dart';
import '../components/welcome_dialog.dart';
import '../config.dart';
import '../graphql/schema.graphql.dart';
import '../components/titles_filter_dialog.dart';
import '../components/title_page_item.dart';
import '../components/sentitive_page_view.dart';
import '../constants.dart';
import '../graphql/queries/titles.graphql.dart';
import '../components/ad_banner.dart';
import '../settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.queryParams, this.extraParams});

  final HomeQueryParams? queryParams;
  final HomeExtraParams? extraParams;

  String? get query => queryParams?.query;
  Enum$TitleMediaType? get mediaType => queryParams?.mediaType;
  List<String>? get genreIds => queryParams?.genreIds;
  List<String>? get watchProviderIds => queryParams?.watchProviderIds;
  String? get countryCode => queryParams?.countryCode;
  int? get page => queryParams?.page;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _queryController = TextEditingController();
  bool _isActive = true;

  bool get _hasFilters => widget.queryParams?.hasFilters == true;

  bool get _hasQuery => widget.queryParams?.hasQuery == true;

  Widget _getTitles() {
    final textTheme = TextTheme.of(context);

    return Query$Titles$Widget(
      options: Options$Query$Titles(
        fetchPolicy: FetchPolicy.noCache,
        typedOptimisticResult: widget.extraParams?.parsedData,
        variables: Variables$Query$Titles(
          first: widget.extraParams?.parsedData?.titles.nodes.length ?? (widget.page ?? 0) + 10,
          query: widget.query,
          mediaType: widget.mediaType,
          genreIds: widget.genreIds,
          watchProviderIds: widget.watchProviderIds,
          countryCode: widget.countryCode,
          includeViewed: _hasFilters || _hasQuery,
          includeWithoutVideos: _hasFilters || _hasQuery,
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
          initialPage: widget.page ?? 0,
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
                  includeWithoutVideos: _hasFilters || _hasQuery,
                ),
                updateQuery: (previousResultData, fetchMoreResultData) {
                  if (fetchMoreResultData == null || fetchMoreResultData['titles']['nodes'].length == 0) {
                    return previousResultData;
                  }

                  fetchMoreResultData['titles']['nodes'] = [
                    ...previousResultData?['titles']['nodes'],
                    ...Config.hasAds ? [adTitleObject] : [],
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

          itemBuilder: (context, index, isActive) {
            final title = titles!.nodes[index];

            if (title.id == 'ad') {
              return const AdBanner();
            }

            return TitlePageItem(
              key: PageStorageKey(title.id),
              isActive: _isActive && isActive,
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
          itemCount: titles?.nodes.length ?? 0,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _queryController.text = widget.query ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Settings.getShowWelcome() && mounted) {
        setState(() {
          _isActive = false;
        });

        await showWelcomeDialog(context).then((_) {
          setState(() {
            _isActive = true;
          });

          Settings.setShowWelcome(false);
        });
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTitle(
      title: 'Home',
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: colorTranslucent,
          scrolledUnderElevation: 0,
          title: SearchField(
            controller: _queryController,
            readOnly: true,
            onTap: () {
              SearchDialog(context, queryParams: widget.queryParams);
            },
            onClear: () {
              final queryParams = widget.queryParams!;

              queryParams.query = null;
              queryParams.page = null;

              context.goNamed(routeNameHome, queryParameters: queryParams.toMap());
            },
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: IconButton.outlined(
                isSelected: _hasFilters,
                icon: Icon(Icons.filter_alt_outlined, color: _hasFilters ? Colors.black : null),
                onPressed: () {
                  TitlesFilterDialog(context, queryParams: widget.queryParams);
                },
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 12), child: AccountButton()),
          ],
        ),
        body: Stack(
          children: [
            _getTitles(),
            SafeArea(child: FiltersRow(queryParams: widget.queryParams)),
          ],
        ),
      ),
    );
  }
}

class HomeQueryParams {
  HomeQueryParams({this.query, this.mediaType, this.genreIds, this.watchProviderIds, this.countryCode, this.page});

  String? query;
  Enum$TitleMediaType? mediaType;
  final List<String>? genreIds;
  final List<String>? watchProviderIds;
  final String? countryCode;
  int? page;

  bool get hasQuery => query != null && query!.length > 1;
  bool get hasFilters => mediaType != null || genreIds != null || watchProviderIds != null;

  static HomeQueryParams fromMap(Map<String, String> value) {
    final String? query = value[keyQuery];
    final String? mediaTypeStr = value[keyMediaType];
    final genreIds = value[keyGenreIds]?.split(',');
    final watchProviderIds = value[keyWatchProviderIds]?.split(',');
    final countryCode = value[keyCountryCode];
    final page = int.tryParse(value[keyPage] ?? '');

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
      page: page,
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

    if (page != null) {
      queryParams[keyPage] = page!.toString();
    }

    return queryParams;
  }
}

class HomeExtraParams {
  HomeExtraParams({required this.parsedData});

  final Query$Titles? parsedData;
}
