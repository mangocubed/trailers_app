import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:toolbox/identity_client.dart';

import '../config.dart';
import '../constants.dart';
import '../graphql/fragments/title_stat_fragment.graphql.dart';
import '../graphql/fragments/user_title_tie_fragment.graphql.dart';
import '../graphql/mutations/update_bookmark.graphql.dart';
import '../graphql/mutations/update_like.graphql.dart';
import '../graphql/mutations/update_watched.graphql.dart';
import '../graphql/schema.graphql.dart';
import '../graphql/queries/title_current_user_tie.graphql.dart';
import '../graphql_client.dart';
import 'counter_button.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key, required this.direction, required this.titleId, required this.titleStat});

  final Axis direction;
  final String titleId;
  final Fragment$TitleStatFragment titleStat;

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  Refetch<Query$TitleCurrentUserTie>? _refetch;

  void _updateCache(BuildContext context, Fragment$UserTitleTieFragment? userTitleTie) {
    if (userTitleTie == null) {
      return;
    }

    context.graphQLClient.value.writeFragment$UserTitleTieFragment(
      data: userTitleTie,
      idFields: {'id': userTitleTie.id, '__typename': userTitleTie.$__typename},
      broadcast: true,
    );
  }

  Future<void> _onBookmarkPressed(BuildContext context, bool isChecked) async {
    final result = await context.graphQLClient.value.mutate$UpdateBookmark(
      Options$Mutation$UpdateBookmark(
        variables: Variables$Mutation$UpdateBookmark(
          input: Input$UserTitleTieInputObject(titleId: widget.titleId, isChecked: isChecked),
        ),
      ),
    );

    if (context.mounted) {
      _updateCache(context, result.parsedData?.updateBookmark);
    }
  }

  Future<void> _onLikePressed(BuildContext context, bool isChecked) async {
    final result = await context.graphQLClient.value.mutate$UpdateLike(
      Options$Mutation$UpdateLike(
        variables: Variables$Mutation$UpdateLike(
          input: Input$UserTitleTieInputObject(titleId: widget.titleId, isChecked: isChecked),
        ),
      ),
    );

    if (context.mounted) {
      _updateCache(context, result.parsedData?.updateLike);
    }
  }

  Future<void> _onWatchedPressed(BuildContext context, bool isChecked) async {
    final result = await context.graphQLClient.value.mutate$UpdateWatched(
      Options$Mutation$UpdateWatched(
        variables: Variables$Mutation$UpdateWatched(
          input: Input$UserTitleTieInputObject(titleId: widget.titleId, isChecked: isChecked),
        ),
      ),
    );

    if (context.mounted) {
      _updateCache(context, result.parsedData?.updateWatched);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Query$TitleCurrentUserTie$Widget(
      options: Options$Query$TitleCurrentUserTie(variables: Variables$Query$TitleCurrentUserTie(id: widget.titleId)),
      builder: (result, {fetchMore, refetch}) {
        final userTitleTie = result.parsedData?.title?.currentUserTie;

        _refetch ??= refetch;

        final isWatched = userTitleTie?.isWatched ?? false;
        final isLiked = userTitleTie?.isLiked ?? false;
        final isBookmarked = userTitleTie?.isBookmarked ?? false;

        return Container(
          decoration: BoxDecoration(color: colorTranslucent, borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(4),
          child: Flex(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            direction: widget.direction,
            children: [
              CounterButton(
                onPressed: () {
                  IdentityClient.withAuthentication(context, (context) async {
                    await _onWatchedPressed(context, !isWatched);

                    await refetch?.call();
                  });
                },
                icon: SvgPicture.asset(isWatched ? 'assets/watched_filled.svg' : 'assets/watched.svg'),
                count: widget.titleStat.watchCount,
                isSelected: isWatched,
                tooltip: 'Watched',
                colorSelected: colorWatchedFilled,
              ),
              CounterButton(
                onPressed: () {
                  IdentityClient.withAuthentication(context, (context) async {
                    await _onLikePressed(context, !isLiked);

                    await refetch?.call();
                  });
                },
                icon: SvgPicture.asset(isLiked ? 'assets/heart_filled.svg' : 'assets/heart.svg'),
                count: widget.titleStat.likesCount,
                isSelected: isLiked,
                tooltip: 'Like',
                colorSelected: colorHeartFilled,
              ),
              CounterButton(
                onPressed: () {
                  IdentityClient.withAuthentication(context, (context) async {
                    await _onBookmarkPressed(context, !isBookmarked);

                    await refetch?.call();
                  });
                },
                icon: SvgPicture.asset(isBookmarked ? 'assets/bookmark_filled.svg' : 'assets/bookmark.svg'),
                count: widget.titleStat.bookmarksCount,
                tooltip: 'Bookmark',
                isSelected: isBookmarked,
              ),
              IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(uri: Config.trailersUrl.replace(path: '/titles/${widget.titleId}')),
                  );
                },
                icon: SvgPicture.asset('assets/share.svg'),
                tooltip: 'Share',
              ),
            ],
          ),
        );
      },
    );
  }
}
