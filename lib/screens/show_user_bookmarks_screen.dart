import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../components/sentitive_page_view.dart';
import '../constants.dart';
import '../components/user_button.dart';
import '../graphql/queries/user_title_ties.graphql.dart';
import '../screens/show_video_screen.dart';

class ShowUserBookmarksScreen extends StatefulWidget {
  const ShowUserBookmarksScreen({super.key, required this.username, this.extra});

  final String username;
  final ShowUserBookmarksExtra? extra;

  @override
  State<ShowUserBookmarksScreen> createState() => _ShowUserBookmarksScreenState();
}

class _ShowUserBookmarksScreenState extends State<ShowUserBookmarksScreen> {
  late PageController _pageController;

  int get _currentPage => _pageController.page?.round() ?? 0;

  Widget _getBookmarksVideos() {
    return Query$UserTitleTies$Widget(
      options: Options$Query$UserTitleTies(
        typedOptimisticResult: widget.extra?.parsedData,
        variables: Variables$Query$UserTitleTies(
          username: widget.username,
          isBookmarked: true,
          first: widget.extra?.parsedData?.user?.titleTies.nodes.length ?? 12,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titleTies = result.parsedData?.user?.titleTies;

        _pageController = PageController(initialPage: widget.extra?.page ?? 0);

        return SensitivePageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {});

            if (result.isLoading || (titleTies?.nodes.length ?? 0) > page + 5) {
              return;
            }

            fetchMore?.call(
              FetchMoreOptions$Query$UserTitleTies(
                variables: Variables$Query$UserTitleTies(
                  username: widget.username,
                  isBookmarked: true,
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
          },
          itemBuilder: (context, index) {
            final title = titleTies!.nodes[index].title;

            return ShowVideoScreen(
              title: title,
              index: index,
              currentPage: _currentPage,
              onSeeMore: () => context.goNamed(
                routeNameShowUserBookmarksTitle,
                pathParameters: {keyUsername: widget.username, keyTitleId: title.id},
              ),
            );
          },
          itemCount: titleTies?.nodes.length,
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
              SvgPicture.asset('assets/bookmark.svg'),
              const SizedBox(width: 16),
              Text('@${widget.username}\'s bookmarks', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: UserButton())],
      ),
      body: _getBookmarksVideos(),
    );
  }
}

class ShowUserBookmarksExtra {
  ShowUserBookmarksExtra({required this.parsedData, required this.page});

  final Query$UserTitleTies? parsedData;
  final int page;
}
