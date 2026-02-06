import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trailers/graphql/fragments/user_title_tie_fragment.graphql.dart';

import '../constants.dart';
import '../graphql/mutations/update_bookmark.graphql.dart';
import '../graphql/mutations/update_like.graphql.dart';
import '../graphql/mutations/update_watched.graphql.dart';
import '../graphql/schema.graphql.dart';
import '../graphql_client.dart';
import '../session.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key, required this.direction, required this.titleId, this.videoId, this.userTitleTie});

  final Axis direction;
  final String titleId;
  final String? videoId;
  final Fragment$UserTitleTieFragment? userTitleTie;

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  late Fragment$UserTitleTieFragment? _userTitleTie;

  void _setUserTitleTie(Fragment$UserTitleTieFragment? userTitleTie) {
    if (userTitleTie != null && mounted) {
      setState(() {
        _userTitleTie = userTitleTie;
      });
    }
  }

  void _onBookmarkPressed() async {
    if (await Session.isAuthenticated() && mounted) {
      final result = await context.graphQLClient.value.mutate$UpdateBookmark(
        Options$Mutation$UpdateBookmark(
          variables: Variables$Mutation$UpdateBookmark(
            input: Input$UserTitleTieInputObject(
              titleId: widget.titleId,
              videoId: widget.videoId,
              isChecked: _userTitleTie?.isBookmarked != true,
            ),
          ),
        ),
      );

      final userTitleTie = result.parsedData?.updateBookmark;

      _setUserTitleTie(userTitleTie);
    } else if (mounted) {
      context.goNamed(routeNameLogin);
    }
  }

  void _onLikePressed() async {
    if (await Session.isAuthenticated() && mounted) {
      final result = await context.graphQLClient.value.mutate$UpdateLike(
        Options$Mutation$UpdateLike(
          variables: Variables$Mutation$UpdateLike(
            input: Input$UserTitleTieInputObject(
              titleId: widget.titleId,
              videoId: widget.videoId,
              isChecked: _userTitleTie?.isLiked != true,
            ),
          ),
        ),
      );

      final userTitleTie = result.parsedData?.updateLike;

      _setUserTitleTie(userTitleTie);
    } else if (mounted) {
      context.goNamed(routeNameLogin);
    }
  }

  void _onWatchedPressed() async {
    if (await Session.isAuthenticated() && mounted) {
      final result = await context.graphQLClient.value.mutate$UpdateWatched(
        Options$Mutation$UpdateWatched(
          variables: Variables$Mutation$UpdateWatched(
            input: Input$UserTitleTieInputObject(
              titleId: widget.titleId,
              videoId: widget.videoId,
              isChecked: _userTitleTie?.isWatched != true,
            ),
          ),
        ),
      );

      final userTitleTie = result.parsedData?.updateWatched;

      _setUserTitleTie(userTitleTie);
    } else if (mounted) {
      context.goNamed(routeNameLogin);
    }
  }

  @override
  void initState() {
    super.initState();

    _userTitleTie = widget.userTitleTie;
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.direction,
      children: [
        IconButton(
          onPressed: _onWatchedPressed,
          icon: SvgPicture.asset(
            widget.userTitleTie?.isWatched == true ? 'assets/watched_filled.svg' : 'assets/watched.svg',
          ),
          tooltip: 'Watched',
        ),
        const SizedBox(height: 8, width: 8),
        IconButton(
          onPressed: _onLikePressed,
          icon: SvgPicture.asset(widget.userTitleTie?.isLiked == true ? 'assets/heart_filled.svg' : 'assets/heart.svg'),
          tooltip: 'Like',
        ),
        const SizedBox(height: 8, width: 8),
        IconButton(
          onPressed: _onBookmarkPressed,
          icon: SvgPicture.asset(
            widget.userTitleTie?.isBookmarked == true ? 'assets/bookmark_filled.svg' : 'assets/bookmark.svg',
          ),
          tooltip: 'Bookmark',
        ),
      ],
    );
  }
}
