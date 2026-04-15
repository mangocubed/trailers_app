import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../components/account_button.dart';
import '../components/ad_banner.dart';
import '../components/screen_title.dart';
import '../components/sentitive_page_view.dart';
import '../components/title_page_item.dart';
import '../config.dart';
import '../constants.dart';
import '../graphql/queries/user_title_ties.graphql.dart';
import 'show_user_screen.dart';

class ShowUserBookmarksScreen extends StatefulWidget {
  const ShowUserBookmarksScreen({super.key, required this.username, this.queryParams, this.extraParams});

  final String username;
  final UserQueryParams? queryParams;
  final UserExtraParams? extraParams;

  int? get page => queryParams?.page;

  @override
  State<ShowUserBookmarksScreen> createState() => _ShowUserBookmarksScreenState();
}

class _ShowUserBookmarksScreenState extends State<ShowUserBookmarksScreen> {
  Widget _getBookmarksVideos() {
    return Query$UserTitleTies$Widget(
      options: Options$Query$UserTitleTies(
        fetchPolicy: FetchPolicy.noCache,
        typedOptimisticResult: widget.extraParams?.parsedData,
        variables: Variables$Query$UserTitleTies(
          username: widget.username,
          isBookmarked: true,
          first: widget.extraParams?.parsedData?.user?.titleTies.nodes.length ?? (widget.page ?? 0) + 10,
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        final titleTies = result.parsedData?.user?.titleTies;

        return SensitivePageView(
          initialPage: widget.page ?? 0,
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
                    ...Config.hasAds ? [adTitleObject] : [],
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
          itemBuilder: (context, index, isActive) {
            final title = titleTies!.nodes[index].title;

            if (title.id == 'ad') {
              return const AdBanner();
            }

            return TitlePageItem(
              key: PageStorageKey(title.id),
              title: title,
              isActive: isActive,
              onSeeMore: () => context.goNamed(
                routeNameShowUserBookmarksTitle,
                pathParameters: {keyUsername: widget.username, keyTitleId: title.id},
                queryParameters: widget.queryParams?.toMap() ?? {},
              ),
            );
          },
          itemCount: titleTies?.nodes.length ?? 0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTitle(
      title: '@${widget.username} > Bookmarks',
      child: Scaffold(
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
          actions: const [Padding(padding: EdgeInsets.only(right: 12), child: AccountButton())],
        ),
        body: _getBookmarksVideos(),
      ),
    );
  }
}
