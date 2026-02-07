import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../components/user_button.dart';
import '../graphql/queries/user_title_ties.graphql.dart';
import '../screens/show_video_screen.dart';

class ShowUserWatchedScreen extends StatefulWidget {
  const ShowUserWatchedScreen({super.key, required this.username, this.extra});

  final String username;
  final ShowUserWatchedExtra? extra;

  @override
  State<ShowUserWatchedScreen> createState() => _ShowUserWatchedScreenState();
}

class _ShowUserWatchedScreenState extends State<ShowUserWatchedScreen> {
  PageController? _pageController;

  int get _currentPage => _pageController?.page?.round() ?? 0;

  Widget _getWatchedVideos() {
    return Query$UserTitleTies$Widget(
      options: Options$Query$UserTitleTies(
        typedOptimisticResult: widget.extra?.parsedData,
        variables: Variables$Query$UserTitleTies(
          username: widget.username,
          isWatched: true,
          first: widget.extra?.parsedData?.user?.titleTies.nodes.length ?? 12,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titleTies = result.parsedData?.user?.titleTies;

        _pageController = PageController(initialPage: widget.extra?.page ?? 0);

        return NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() {});

            if (result.isLoading || (titleTies?.nodes.length ?? 0) > _currentPage + 5) {
              return true;
            }

            fetchMore?.call(
              FetchMoreOptions$Query$UserTitleTies(
                variables: Variables$Query$UserTitleTies(
                  username: widget.username,
                  isWatched: true,
                  after: result.parsedData?.user?.titleTies.pageInfo.endCursor,
                ),
                updateQuery: (previousResultData, fetchMoreResultData) {
                  if (fetchMoreResultData == null || fetchMoreResultData['user']['titleTies']['nodes'].length == 0) {
                    return previousResultData;
                  }

                  fetchMoreResultData['user']['titleTies']['nodes'] = [
                    ...previousResultData?['user']['titleTies']['nodes'],
                    ...fetchMoreResultData['user']['titleTies']['nodes']
                        .where(
                          (node) =>
                              previousResultData?['user']['titleTies']['nodes']
                                  .map((node1) => node1['id'])
                                  .contains(node['id']) !=
                              true,
                        )
                        .toList(),
                  ];

                  fetchMoreResultData['user']['titleTies']['pageInfo']['startCursor'] =
                      previousResultData?['user']['titleTies']['pageInfo']['startCursor'];

                  return fetchMoreResultData;
                },
              ),
            );

            return true;
          },
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final video = titleTies!.nodes[index].title.videos.nodes.first;

              return ShowVideoScreen(
                video: video,
                index: index,
                currentPage: _currentPage,
                onSeeMore: () => context.goNamed(
                  routeNameShowUserWatchedTitle,
                  pathParameters: {keyUsername: widget.username, keyTitleId: video.title.id},
                  queryParameters: {keyVideoId: video.id},
                ),
              );
            },
            itemCount: titleTies?.nodes.length,
          ),
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
            children: [
              SvgPicture.asset('assets/watched.svg'),
              const SizedBox(width: 16),
              Text('Watched by @${widget.username}', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: UserButton())],
      ),
      body: _getWatchedVideos(),
    );
  }
}

class ShowUserWatchedExtra {
  ShowUserWatchedExtra({required this.parsedData, required this.page});

  final Query$UserTitleTies? parsedData;
  final int page;
}
