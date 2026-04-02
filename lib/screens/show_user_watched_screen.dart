import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trailers/config.dart';

import '../components/ad_banner.dart';
import '../components/sentitive_page_view.dart';
import '../components/title_video.dart';
import '../components/user_button.dart';
import '../constants.dart';
import '../graphql/queries/user_title_ties.graphql.dart';
import 'show_user_screen.dart';

class ShowUserWatchedScreen extends StatefulWidget {
  const ShowUserWatchedScreen({super.key, required this.username, this.queryParams, this.extraParams});

  final String username;
  final UserQueryParams? queryParams;
  final UserExtraParams? extraParams;

  int? get page => queryParams?.page;

  @override
  State<ShowUserWatchedScreen> createState() => _ShowUserWatchedScreenState();
}

class _ShowUserWatchedScreenState extends State<ShowUserWatchedScreen> {
  late PageController _pageController;

  int get _currentPage => _pageController.page?.round() ?? 0;

  Widget _getWatchedVideos() {
    return Query$UserTitleTies$Widget(
      options: Options$Query$UserTitleTies(
        typedOptimisticResult: widget.extraParams?.parsedData,
        variables: Variables$Query$UserTitleTies(
          username: widget.username,
          isWatched: true,
          first: widget.extraParams?.parsedData?.user?.titleTies.nodes.length ?? 10,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titleTies = result.parsedData?.user?.titleTies;

        _pageController = PageController(initialPage: widget.page ?? 0);

        return SensitivePageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {});

            if (result.isLoading || (titleTies?.nodes.length ?? 0) > _currentPage + 5) {
              return;
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
                    ...Config.adUrl != null
                        ? [
                            {
                              'id': 'ad',
                              'title': {
                                'id': 'ad',
                                'mediaType': '',
                                'name': '',
                                'crew': {'nodes': [], '__typename': ''},
                                'genres': {'nodes': [], '__typename': ''},
                                'videos': {'nodes': [], '__typename': ''},
                                'createdAt': DateTime.now().toIso8601String(),
                                '__typename': '',
                              },
                              'createdAt': DateTime.now().toIso8601String(),
                              '__typename': '',
                            },
                          ]
                        : [],
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

                  return fetchMoreResultData;
                },
              ),
            );
          },
          itemBuilder: (context, index) {
            final title = titleTies!.nodes[index].title;

            if (title.id == 'ad') {
              return const AdBanner();
            }

            return TitleVideo(
              key: ValueKey(title.id),
              title: title,
              isActive: index == _currentPage,
              onSeeMore: () => context.goNamed(
                routeNameShowUserWatchedTitle,
                pathParameters: {keyUsername: widget.username, keyTitleId: title.id},
                queryParameters: widget.queryParams?.toMap() ?? {},
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
