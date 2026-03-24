import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trailers/components/filters_row.dart';

import 'search_field.dart';
import 'title_card.dart';
import '../constants.dart';
import '../graphql/queries/titles.graphql.dart';
import '../screens/home_screen.dart';

class SearchDialog {
  SearchDialog(BuildContext context, {HomeQueryParams? queryParams}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      fullscreenDialog: true,
      builder: (context) {
        return Dialog.fullscreen(child: _SearchDialogBody(queryParams: queryParams));
      },
    );
  }
}

class _SearchDialogBody extends StatefulWidget {
  const _SearchDialogBody({this.queryParams});

  final HomeQueryParams? queryParams;

  String? get query => queryParams?.query;

  @override
  State<_SearchDialogBody> createState() => _SearchDialogBodyState();
}

class _SearchDialogBodyState extends State<_SearchDialogBody> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  String? _endCursor;
  Function(FetchMoreOptions$Query$Titles)? _fetchMore;

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchMore?.call(
        FetchMoreOptions$Query$Titles(
          variables: Variables$Query$Titles(
            after: _endCursor,
            query: _query,
            mediaType: widget.queryParams?.mediaType,
            genreIds: widget.queryParams?.genreIds,
            watchProviderIds: widget.queryParams?.watchProviderIds,
            countryCode: widget.queryParams?.countryCode,
            includeViewed: true,
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
                        previousResultData?['titles']['nodes'].map((node1) => node1['id']).contains(node['id']) != true,
                  )
                  .toList(),
            ];

            return fetchMoreResultData;
          },
        ),
      );
    }
  }

  @override
  void initState() {
    _query = widget.queryParams?.query ?? '';
    _queryController.text = _query;
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SearchField(
          controller: _queryController,
          autofocus: true,
          onChanged: (text) {
            setState(() => _query = text);
          },
          onClear: () {
            setState(() => _query = '');
          },
        ),
        actions: [
          SizedBox(width: 52),
          Padding(padding: EdgeInsets.only(right: 12), child: CloseButton()),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FiltersRow(queryParams: widget.queryParams),
          Expanded(
            child: _query.length > 1
                ? Query$Titles$Widget(
                    options: Options$Query$Titles(
                      variables: Variables$Query$Titles(
                        first: 12,
                        query: _query,
                        mediaType: widget.queryParams?.mediaType,
                        genreIds: widget.queryParams?.genreIds,
                        watchProviderIds: widget.queryParams?.watchProviderIds,
                        countryCode: widget.queryParams?.countryCode,
                        includeViewed: true,
                      ),
                    ),
                    builder: (result, {fetchMore, refetch}) {
                      final titles = result.parsedData?.titles;

                      if (result.parsedData == null && result.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (titles?.nodes.isNotEmpty != true) {
                        return Center(child: Text('No results for "$_query" 💨', style: textTheme.bodyLarge));
                      }

                      _endCursor = titles?.pageInfo.endCursor;
                      _fetchMore = fetchMore;

                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              delegate: SliverChildListDelegate(
                                titles?.nodes
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => TitleCard(
                                            title: entry.value,
                                            onTap: () {
                                              context.goNamed(
                                                routeNameHome,
                                                queryParameters: HomeQueryParams(
                                                  query: _query,
                                                  mediaType: widget.queryParams?.mediaType,
                                                  genreIds: widget.queryParams?.genreIds,
                                                  watchProviderIds: widget.queryParams?.watchProviderIds,
                                                  countryCode: widget.queryParams?.countryCode,
                                                ).toMap(),
                                                extra: HomeExtraParams(parsedData: result.parsedData, page: entry.key),
                                              );
                                              context.pop();
                                            },
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 9 / 16,
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              result.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Center(child: CircularProgressIndicator()),
                                    )
                                  : const SizedBox(),
                            ]),
                          ),
                        ],
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
