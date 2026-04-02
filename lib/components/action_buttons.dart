import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

import '../components/screen_lifecycle.dart';
import '../config.dart';
import '../constants.dart';
import '../graphql/fragments/user_title_tie_fragment.graphql.dart';
import '../graphql/mutations/update_bookmark.graphql.dart';
import '../graphql/mutations/update_like.graphql.dart';
import '../graphql/mutations/update_watched.graphql.dart';
import '../graphql/schema.graphql.dart';
import '../graphql/queries/title_current_user_tie.graphql.dart';
import '../graphql_client.dart';
import '../identity_client.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.direction, required this.titleId});

  final Axis direction;
  final String titleId;

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
          input: Input$UserTitleTieInputObject(titleId: titleId, isChecked: isChecked),
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
          input: Input$UserTitleTieInputObject(titleId: titleId, isChecked: isChecked),
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
          input: Input$UserTitleTieInputObject(titleId: titleId, isChecked: isChecked),
        ),
      ),
    );

    if (context.mounted) {
      _updateCache(context, result.parsedData?.updateWatched);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query$TitleCurrentUserTie$Widget(
      options: Options$Query$TitleCurrentUserTie(variables: Variables$Query$TitleCurrentUserTie(id: titleId)),
      builder: (result, {fetchMore, refetch}) {
        final userTitleTie = result.parsedData?.title?.currentUserTie;

        final isWatched = userTitleTie?.isWatched ?? false;
        final isLiked = userTitleTie?.isLiked ?? false;
        final isBookmarked = userTitleTie?.isBookmarked ?? false;

        return ScreenLifecycle(
          onResume: () async {
            if (!result.isLoading) {
              try {
                await refetch?.call();
              } catch (_) {}
            }
          },
          child: Container(
            decoration: BoxDecoration(color: colorTranslucent, borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.all(4),
            child: Flex(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              direction: direction,
              children: [
                IconButton(
                  onPressed: () async {
                    final isAuthorized = await IdentityClient.isAuthorized();

                    if (!context.mounted) {
                      return;
                    }

                    if (isAuthorized) {
                      await _onWatchedPressed(context, !isWatched);

                      await refetch?.call();
                    } else {
                      await IdentityClient.authorize(context);
                    }
                  },
                  icon: SvgPicture.asset(isWatched ? 'assets/watched_filled.svg' : 'assets/watched.svg'),
                  tooltip: 'Watched',
                ),
                IconButton(
                  onPressed: () async {
                    final isAuthorized = await IdentityClient.isAuthorized();

                    if (!context.mounted) {
                      return;
                    }

                    if (isAuthorized) {
                      await _onLikePressed(context, !isLiked);

                      await refetch?.call();
                    } else {
                      await IdentityClient.authorize(context);
                    }
                  },
                  icon: SvgPicture.asset(isLiked ? 'assets/heart_filled.svg' : 'assets/heart.svg'),
                  tooltip: 'Like',
                ),
                IconButton(
                  onPressed: () async {
                    final isAuthorized = await IdentityClient.isAuthorized();

                    if (!context.mounted) {
                      return;
                    }

                    if (isAuthorized) {
                      await _onBookmarkPressed(context, !isBookmarked);

                      await refetch?.call();
                    } else {
                      await IdentityClient.authorize(context);
                    }
                  },
                  icon: SvgPicture.asset(isBookmarked ? 'assets/bookmark_filled.svg' : 'assets/bookmark.svg'),
                  tooltip: 'Bookmark',
                ),
                IconButton(
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Check out this title on Trailers: ${Config.trailersUrl.replace(fragment: '/titles/$titleId')}',
                      ),
                    );
                  },
                  icon: SvgPicture.asset('assets/share.svg'),
                  tooltip: 'Share',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
