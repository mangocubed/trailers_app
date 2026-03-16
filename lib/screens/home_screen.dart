import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../components/sentitive_page_view.dart';
import '../components/user_button.dart';
import '../constants.dart';
import '../graphql/queries/titles.graphql.dart';
import 'show_video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  bool _resultsChanged = false;

  int get _currentPage => _pageController.page?.round() ?? 0;

  Widget _getRecommendedTitles() {
    return Query$Titles$Widget(
      options: Options$Query$Titles(fetchPolicy: FetchPolicy.noCache),
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
                  style: TextStyle(fontSize: 18, color: Colors.white),
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
                variables: Variables$Query$Titles(after: _resultsChanged ? null : titles.pageInfo.endCursor),
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
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: UserButton())],
      ),
      body: _getRecommendedTitles(),
    );
  }
}
