import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/current_user.dart';
import '../components/action_buttons.dart';
import '../components/genre_chip.dart';
import '../components/title_basic_info.dart';
import '../graphql/fragments/title_fragment.graphql.dart';
import '../graphql/fragments/video_fragment.graphql.dart';
import '../graphql/queries/title_watch_providers.graphql.dart';
import '../constants.dart';
import '../utils.dart';
import 'title_video_player.dart';

class TitlePageItem extends StatefulWidget {
  const TitlePageItem({
    super.key,
    required this.title,
    required this.isActive,
    required this.onSeeMore,
    this.countryCode,
  });

  final bool isActive;
  final Fragment$TitleFragment title;
  final void Function() onSeeMore;
  final String? countryCode;

  @override
  createState() => _TitlePageItemState();
}

class _TitlePageItemState extends State<TitlePageItem> {
  bool _isInitialized = false;
  bool _play = false;

  Fragment$VideoFragment? get _video => widget.title.videos.nodes.firstOrNull;

  double get _thumbnailOpacity {
    if (_isInitialized) {
      return 0.0;
    } else {
      return 1.0;
    }
  }

  void _togglePlayPause() async {
    setState(() {
      _play = !_isInitialized || !_play;
    });
  }

  @override
  void initState() {
    super.initState();

    _play = widget.isActive;

    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        createUserTitleTie(context, widget.title);
      });
    }
  }

  @override
  didUpdateWidget(TitlePageItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      _isInitialized = false;
      _play = widget.isActive;

      if (widget.isActive) {
        createUserTitleTie(context, widget.title);
      }
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _play = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Stack(
          children: [
            Center(
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: screenSize.height,
                child: widget.isActive && _video != null
                    ? TitleVideoPlayer(
                        video: _video!,
                        play: _play,
                        onInitialize: () {
                          setState(() {
                            _isInitialized = true;
                          });
                        },
                      )
                    : SizedBox(),
              ),
            ),
            widget.title.posterImageUrl != null
                ? AnimatedOpacity(
                    opacity: _thumbnailOpacity,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      color: Colors.black,
                      width: screenSize.width,
                      height: screenSize.height,
                      child: Center(child: Image.network(widget.title.posterImageUrl!.toString())),
                    ),
                  )
                : const SizedBox(),
            _video != null
                ? InkWell(
                    onTap: _togglePlayPause,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Visibility(
                        visible: !_isInitialized || !_play,
                        child: Center(
                          child: Icon(
                            _isInitialized ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: colorPlayIcon,
                            size: 128,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionButtons(
              key: ValueKey(widget.title.id),
              direction: Axis.vertical,
              titleId: widget.title.id,
              titleStat: widget.title.stat,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 12, right: 24, bottom: 12, left: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0),
                  Color.fromRGBO(0, 0, 0, 0.33),
                  Color.fromRGBO(0, 0, 0, 0.66),
                  Color(0xFF000000),
                  Color(0xFF000000),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title.name,
                  style: GoogleFonts.blackHanSans(
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flex(
                  direction: isPortrait ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: isPortrait ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: isPortrait ? 0 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleBasicInfo(
                            isCentered: false,
                            releasedOn: widget.title.releasedOn,
                            directorName: widget.title.crew.nodes.firstOrNull?.person.name,
                            runtime: widget.title.runtime,
                            mediaType: widget.title.mediaType,
                            extraChips: widget.title.genres.nodes
                                .map((genre) => Flexible(child: GenreChip(name: genre.name)))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          CurrentUser(
                            builder: (user, {refetch}) {
                              return Query$TitleWatchProviders$Widget(
                                options: Options$Query$TitleWatchProviders(
                                  variables: Variables$Query$TitleWatchProviders(
                                    id: widget.title.id,
                                    countryCode: widget.countryCode ?? user?.identityUser.countryCode ?? 'US',
                                  ),
                                ),
                                builder: (result, {fetchMore, refetch}) {
                                  final titleWatchProviders = result.parsedData?.title?.watchProviders;

                                  if (titleWatchProviders?.nodes.isNotEmpty != true) {
                                    return const SizedBox();
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: titleWatchProviders!.nodes
                                          .map(
                                            (watchProvider) => IconButton(
                                              onPressed: () async {
                                                if (watchProvider.watchProvider.homeUrl != null &&
                                                    await canLaunchUrl(watchProvider.watchProvider.homeUrl!)) {
                                                  launchUrl(watchProvider.watchProvider.homeUrl!);
                                                }
                                              },
                                              tooltip: watchProvider.watchProvider.name,
                                              icon: ClipRRect(
                                                borderRadius: BorderRadius.circular(6.0),
                                                child: watchProvider.watchProvider.logoImageUrl != null
                                                    ? Image.network(
                                                        watchProvider.watchProvider.logoImageUrl.toString(),
                                                        height: 32,
                                                      )
                                                    : Text(watchProvider.watchProvider.name),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8, width: 8),
                    Expanded(
                      flex: isPortrait ? 0 : 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            widget.onSeeMore.call();
                            return;
                          },
                          child: Text('MORE DETAILS'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
