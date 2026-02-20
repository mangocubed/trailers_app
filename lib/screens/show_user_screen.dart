import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../components/title_card.dart';
import '../constants.dart';
import '../graphql/queries/user.graphql.dart';
import '../graphql/queries/user_title_ties.graphql.dart';
import '../screens/not_found_screen.dart';
import '../screens/show_user_bookmarks_screen.dart';
import '../screens/show_user_watched_screen.dart';

class ShowUserScreen extends StatefulWidget {
  const ShowUserScreen({super.key, required this.username});

  final String username;

  @override
  State<ShowUserScreen> createState() => _ShowUserScreenState();
}

class _ShowUserScreenState extends State<ShowUserScreen> {
  bool _isInWatched = false;
  final _scrollController = ScrollController();
  String? _bookmarksEndCursor;
  Function(FetchMoreOptions$Query$UserTitleTies)? _bookmarksFetchMore;
  String? _watchedEndCursor;
  Function(FetchMoreOptions$Query$UserTitleTies)? _watchedFetchMore;

  void _scrollListener() {
    if (_scrollController.offset < _scrollController.position.maxScrollExtent ||
        _scrollController.position.outOfRange) {
      return;
    }

    if (_isInWatched) {
      _watchedFetchMore?.call(
        FetchMoreOptions$Query$UserTitleTies(
          variables: Variables$Query$UserTitleTies(
            username: widget.username,
            isWatched: true,
            after: _watchedEndCursor,
            first: 12,
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
    } else {
      _bookmarksFetchMore?.call(
        FetchMoreOptions$Query$UserTitleTies(
          variables: Variables$Query$UserTitleTies(
            username: widget.username,
            isBookmarked: true,
            after: _bookmarksEndCursor,
            first: 12,
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
    }
  }

  Widget _getBookmarks() {
    return Query$UserTitleTies$Widget(
      options: Options$Query$UserTitleTies(
        variables: Variables$Query$UserTitleTies(username: widget.username, isBookmarked: true, first: 12),
      ),
      builder: (result, {fetchMore, refetch}) {
        final user = result.parsedData?.user;

        _bookmarksEndCursor = user?.titleTies.pageInfo.endCursor;
        _bookmarksFetchMore = fetchMore;

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 9 / 16,
          ),
          delegate: SliverChildListDelegate(
            user?.titleTies.nodes
                    .asMap()
                    .entries
                    .map(
                      (entry) => TitleCard(
                        title: entry.value.title,
                        onTap: () => context.goNamed(
                          routeNameShowUserBookmarks,
                          pathParameters: {keyUsername: widget.username},
                          extra: ShowUserBookmarksExtra(parsedData: result.parsedData, page: entry.key),
                        ),
                      ),
                    )
                    .toList() ??
                [],
          ),
        );
      },
    );
  }

  Widget _getWatched() {
    return Query$UserTitleTies$Widget(
      options: Options$Query$UserTitleTies(
        variables: Variables$Query$UserTitleTies(username: widget.username, isWatched: true, first: 12),
      ),
      builder: (result, {fetchMore, refetch}) {
        final user = result.parsedData?.user;

        _watchedEndCursor = user?.titleTies.pageInfo.endCursor;
        _watchedFetchMore = fetchMore;

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 9 / 16,
          ),
          delegate: SliverChildListDelegate(
            user?.titleTies.nodes
                    .asMap()
                    .entries
                    .map(
                      (entry) => TitleCard(
                        title: entry.value.title,
                        onTap: () => context.goNamed(
                          routeNameShowUserWatched,
                          pathParameters: {keyUsername: widget.username},
                          extra: ShowUserWatchedExtra(parsedData: result.parsedData, page: entry.key),
                        ),
                      ),
                    )
                    .toList() ??
                [],
          ),
        );
      },
    );
  }

  @override
  void initState() {
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
    return Query$User$Widget(
      options: Options$Query$User(variables: Variables$Query$User(username: widget.username)),
      builder: (result, {fetchMore, refetch}) {
        final user = result.parsedData?.user;

        if (user == null) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const NotFoundScreen();
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xff353535),
          appBar: AppBar(foregroundColor: Colors.white, backgroundColor: Colors.transparent),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      child: Text(user.identityUser.initials, style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '@${user.identityUser.username}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFC3D350)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 32,
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _isInWatched = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                side: const BorderSide(color: Color(0xFFC3D350)),
                                backgroundColor: !_isInWatched ? const Color(0x66C3D350) : null,
                                foregroundColor: const Color(0xFFC3D350),
                              ),
                              label: Text('Bookmarks'),
                              icon: SvgPicture.asset(
                                'assets/bookmark.svg',
                                colorFilter: const ColorFilter.mode(Color(0xFFC3D350), BlendMode.srcIn),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 32,
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _isInWatched = true),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                side: const BorderSide(color: Color(0xFFC3D350)),
                                backgroundColor: _isInWatched ? const Color(0x66C3D350) : null,
                                foregroundColor: const Color(0xFFC3D350),
                              ),
                              label: Text('Watched'),
                              icon: SvgPicture.asset(
                                'assets/watched.svg',
                                colorFilter: const ColorFilter.mode(Color(0xFFC3D350), BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ]),
              ),
              SliverPadding(padding: const EdgeInsets.all(16), sliver: _isInWatched ? _getWatched() : _getBookmarks()),
            ],
          ),
        );
      },
    );
  }
}
