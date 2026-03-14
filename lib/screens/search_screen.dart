import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../components/title_card.dart';
import '../components/user_button.dart';
import '../graphql/queries/titles.graphql.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.query});

  final String? query;

  @override
  createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scrollController = ScrollController();
  final _queryController = TextEditingController();
  String _queryText = '';
  Timer? _queryTimer;
  String? _endCursor;
  Function(FetchMoreOptions$Query$Titles)? _fetchMore;

  void _updateQuery(String text) {
    _queryTimer?.cancel();

    _queryTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() => _queryText = _queryController.text);
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchMore?.call(
        FetchMoreOptions$Query$Titles(
          variables: Variables$Query$Titles(query: _queryText, after: _endCursor, includeViewed: true),
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

            fetchMoreResultData['titles']['pageInfo']['startCursor'] =
                previousResultData?['titles']['pageInfo']['startCursor'];

            return fetchMoreResultData;
          },
        ),
      );
    }
  }

  @override
  void initState() {
    if (widget.query != null) {
      _queryController.text = widget.query!;
      _queryText = widget.query!;
    }

    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF172121),
        leading: BackButton(color: Colors.white, onPressed: () => context.pop()),
        title: TextField(
          controller: _queryController,
          autofocus: true,
          decoration: InputDecoration(
            constraints: const BoxConstraints(maxHeight: 40),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(16),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 16),
            suffixIcon: _queryController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _queryController.clear();
                      setState(() => _queryText = '');
                    },
                    child: const MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(Icons.highlight_off_rounded),
                    ),
                  )
                : const Icon(Icons.search_rounded),
            suffixIconColor: Colors.white,
            hintText: 'Search',
            hintStyle: const TextStyle(fontSize: 16, color: Colors.white54),
          ),
          minLines: 1,
          maxLines: 1,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          onChanged: _updateQuery,
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: UserButton())],
      ),
      body: _queryController.text.length > 1
          ? Query$Titles$Widget(
              options: Options$Query$Titles(
                variables: Variables$Query$Titles(query: _queryText, first: 12, includeViewed: true),
              ),
              builder: (result, {fetchMore, refetch}) {
                final titles = result.parsedData?.titles;

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
                                      onTap: () => context.goNamed(
                                        routeNameSearchResults,
                                        queryParameters: {keyQuery: _queryController.text},
                                        extra: SearchResultsExtra(parsedData: result.parsedData, page: entry.key),
                                      ),
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
    );
  }
}
