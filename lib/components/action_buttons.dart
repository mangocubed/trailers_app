import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../graphql/mutations/update_bookmark.graphql.dart';
import '../graphql/mutations/update_like.graphql.dart';
import '../graphql/mutations/update_watched.graphql.dart';
import '../graphql/schema.graphql.dart';
import '../graphql_client.dart';
import '../session.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({
    super.key,
    required this.direction,
    required this.titleId,
    required this.isBookmarked,
    required this.isLiked,
    required this.isWatched,
    this.videoId,
    required this.onUpdated,
  });

  final Axis direction;
  final String titleId;
  final String? videoId;
  final bool isBookmarked;
  final bool isLiked;
  final bool isWatched;
  final void Function()? onUpdated;

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  _onBookmarkPressed() async {
    if (await Session.isAuthenticated() && mounted) {
      await context.graphQLClient.value.mutate$UpdateBookmark(
        Options$Mutation$UpdateBookmark(
          variables: Variables$Mutation$UpdateBookmark(
            input: Input$UserTitleTieInputObject(
              titleId: widget.titleId,
              videoId: widget.videoId,
              isChecked: !widget.isBookmarked,
            ),
          ),
        ),
      );

      widget.onUpdated?.call();
    } else if (mounted) {
      context.goNamed(routeNameLogin);
    }
  }

  _onLikePressed() async {
    if (await Session.isAuthenticated() && mounted) {
      await context.graphQLClient.value.mutate$UpdateLike(
        Options$Mutation$UpdateLike(
          variables: Variables$Mutation$UpdateLike(
            input: Input$UserTitleTieInputObject(
              titleId: widget.titleId,
              videoId: widget.videoId,
              isChecked: !widget.isLiked,
            ),
          ),
        ),
      );

      widget.onUpdated?.call();
    } else if (mounted) {
      context.goNamed(routeNameLogin);
    }
  }

  _onWatchedPressed() async {
    if (await Session.isAuthenticated() && mounted) {
      await context.graphQLClient.value.mutate$UpdateWatched(
        Options$Mutation$UpdateWatched(
          variables: Variables$Mutation$UpdateWatched(
            input: Input$UserTitleTieInputObject(
              titleId: widget.titleId,
              videoId: widget.videoId,
              isChecked: !widget.isWatched,
            ),
          ),
        ),
      );

      widget.onUpdated?.call();
    } else if (mounted) {
      context.goNamed(routeNameLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.direction,
      children: [
        IconButton(
          onPressed: _onWatchedPressed,
          icon: SvgPicture.asset(widget.isWatched ? 'assets/watched_filled.svg' : 'assets/watched.svg'),
          tooltip: 'Watched',
        ),
        const SizedBox(height: 8, width: 8),
        IconButton(
          onPressed: _onLikePressed,
          icon: SvgPicture.asset(widget.isLiked ? 'assets/heart_filled.svg' : 'assets/heart.svg'),
          tooltip: 'Like',
        ),
        const SizedBox(height: 8, width: 8),
        IconButton(
          onPressed: _onBookmarkPressed,
          icon: SvgPicture.asset(widget.isBookmarked ? 'assets/bookmark_filled.svg' : 'assets/bookmark.svg'),
          tooltip: 'Bookmark',
        ),
      ],
    );
  }
}
