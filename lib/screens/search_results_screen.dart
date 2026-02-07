import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/sentitive_page_view.dart';
import '../constants.dart';
import '../components/user_button.dart';
import '../graphql/queries/titles.graphql.dart';
import 'show_video_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.query, this.extra});

  final String? query;
  final SearcResultsExtra? extra;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late PageController _pageController;

  int get _currentPage => _pageController.page?.round() ?? 0;

  Widget _getSearchResultVideos() {
    return Query$Titles$Widget(
      options: Options$Query$Titles(
        typedOptimisticResult: widget.extra?.parsedData,
        variables: Variables$Query$Titles(
          query: widget.query,
          first: widget.extra?.parsedData?.titles.nodes.length ?? 12,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titles = result.parsedData?.titles;

        _pageController = PageController(initialPage: widget.extra?.page ?? 0);

        return SensitivePageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {});

            if (result.isLoading || titles.nodes.length > page + 5) {
              return;
            }

            fetchMore?.call(
              FetchMoreOptions$Query$Titles(
                variables: Variables$Query$Titles(
                  query: widget.query,
                  after: result.parsedData?.titles.pageInfo.endCursor,
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

                  fetchMoreResultData['titles']['pageInfo']['startCursor'] =
                      previousResultData?['titles']['pageInfo']['startCursor'];

                  return fetchMoreResultData;
                },
              ),
            );
          },
          itemBuilder: (context, index) {
            final video = titles.nodes[index].videos.nodes.first;

            return ShowVideoScreen(
              video: video,
              index: index,
              currentPage: _currentPage,
              onSeeMore: () => context.goNamed(
                routeNameSearchResultsTitle,
                pathParameters: {keyTitleId: video.title.id},
                queryParameters: {keyQuery: widget.query, keyVideoId: video.id},
              ),
            );
          },
          itemCount: titles!.nodes.length,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: OutlinedButton(
          onPressed: context.pop,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.query ?? '', style: const TextStyle(fontSize: 16, color: Colors.white)),
              const Icon(Icons.search_rounded, color: Colors.white),
            ],
          ),
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: UserButton())],
      ),
      body: _getSearchResultVideos(),
    );
  }
}

class SearcResultsExtra {
  SearcResultsExtra({required this.parsedData, required this.page});

  final Query$Titles? parsedData;
  final int page;
}
