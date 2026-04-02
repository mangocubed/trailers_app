import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../components/current_user.dart';
import '../components/action_buttons.dart';
import '../components/genre_chip.dart';
import '../components/title_basic_info.dart';
import '../graphql/fragments/title_fragment.graphql.dart';
import '../graphql/queries/title_watch_providers.graphql.dart';
import '../router.dart';
import '../utils.dart';

class TitleVideo extends StatefulWidget {
  const TitleVideo({super.key, required this.title, required this.isActive, required this.onSeeMore, this.countryCode});

  final bool isActive;
  final Fragment$TitleFragment title;
  final void Function() onSeeMore;
  final String? countryCode;

  @override
  createState() => _TitleVideoState();
}

class _TitleVideoState extends State<TitleVideo> with RouteAware {
  VideoPlayerController? _videoPlayerController;

  bool get _isReady => _videoPlayerController?.value.isInitialized ?? false;
  bool get _isPlaying => _videoPlayerController?.value.isPlaying ?? false;

  Fragment$TitleFragment$videos$nodes? get _video => widget.title.videos.nodes.firstOrNull;

  double get _thumbnailOpacity {
    if (_isReady) {
      return 0.0;
    } else {
      return 1.0;
    }
  }

  Future<void> _play() async {
    if (_video == null) {
      return;
    }

    final sourceUrl = _video!.hlsUrl != null && !kIsWeb ? _video!.hlsUrl! : _video!.url;

    if (_videoPlayerController?.dataSource != sourceUrl.toString()) {
      await _stop();

      _videoPlayerController = VideoPlayerController.networkUrl(sourceUrl, viewType: VideoViewType.platformView)
        ..setLooping(true)
        ..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
    }

    if (!_isReady) {
      _videoPlayerController?.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

    await _videoPlayerController?.play();
  }

  Future<void> _pause() async {
    await _videoPlayerController?.pause();
  }

  Future<void> _stop() async {
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;

    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  Widget _getVideoPlayer() {
    if (_video == null) {
      return const SizedBox();
    }

    if (_videoPlayerController?.value.isInitialized == true) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      );
    }

    return const CircularProgressIndicator();
  }

  @override
  void initState() {
    super.initState();

    if (widget.isActive) {
      _play();
      createUserTitleTie(context, widget.title);
    }
  }

  @override
  didUpdateWidget(TitleVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (ModalRoute.of(context)?.isCurrent == true && widget.isActive) {
      _play();
      createUserTitleTie(context, widget.title);
    } else if (ModalRoute.of(context)?.isCurrent != true && widget.isActive) {
      _pause();
    } else {
      _stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentRoute = ModalRoute.of(context);

    if (currentRoute != null) {
      routeObserver.subscribe(this, currentRoute);
    }
  }

  @override
  void didPushNext() {
    _stop();
  }

  @override
  void didPopNext() {
    if (widget.isActive) {
      _play();
      createUserTitleTie(context, widget.title);
    }
  }

  @override
  void dispose() {
    _stop();

    routeObserver.unsubscribe(this);

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
              child: OverflowBox(maxWidth: double.infinity, maxHeight: screenSize.height, child: _getVideoPlayer()),
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
                        visible: !_isPlaying,
                        child: Center(
                          child: Icon(
                            _isReady ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Color(0x999E9E9E),
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
            child: ActionButtons(direction: Axis.vertical, titleId: widget.title.id),
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
                                              onPressed: () async {},
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
