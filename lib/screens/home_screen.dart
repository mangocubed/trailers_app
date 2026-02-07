import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../components/user_button.dart';
import '../constants.dart';
import '../graphql/queries/videos.graphql.dart';
import 'show_video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  bool _resultsChanged = false;

  int get _currentPage => _pageController.page?.round() ?? 0;

  Widget _getRecommendedVideos() {
    return Query$Videos$Widget(
      options: Options$Query$Videos(fetchPolicy: FetchPolicy.noCache),
      builder: (result, {fetchMore, refetch}) {
        final videos = result.parsedData?.videos;

        if (result.parsedData == null && result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (videos?.nodes.isNotEmpty != true) {
          return const SizedBox();
        }

        return NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() {});

            if (result.isLoading || videos!.nodes.length > _currentPage + 5) {
              return true;
            }

            fetchMore?.call(
              FetchMoreOptions$Query$Videos(
                variables: Variables$Query$Videos(after: _resultsChanged ? null : videos.pageInfo.endCursor),
                updateQuery: (previousResultData, fetchMoreResultData) {
                  if (fetchMoreResultData == null || fetchMoreResultData['videos']['nodes'].length == 0) {
                    return previousResultData;
                  }

                  _resultsChanged = false;

                  fetchMoreResultData['videos']['nodes'] = [
                    ...previousResultData?['videos']['nodes'],
                    ...fetchMoreResultData['videos']['nodes']
                        .where(
                          (node) =>
                              previousResultData?['videos']['nodes']
                                  .map((node1) => node1['title']['id'])
                                  .contains(node['title']['id']) !=
                              true,
                        )
                        .toList(),
                  ];

                  fetchMoreResultData['videos']['pageInfo']['startCursor'] =
                      previousResultData?['videos']['pageInfo']['startCursor'];

                  return fetchMoreResultData;
                },
              ),
            );

            return true;
          },
          child: PageView.builder(
            controller: _pageController,
            allowImplicitScrolling: true,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final video = videos!.nodes[index];

              return ShowVideoScreen(
                index: index,
                currentPage: _currentPage,
                video: video,
                onUpdated: () => _resultsChanged = true,
              );
            },
            itemCount: result.parsedData?.videos.nodes.length,
          ),
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
      body: _getRecommendedVideos(),
    );
  }
}
