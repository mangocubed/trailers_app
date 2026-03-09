import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../components/action_buttons.dart';
import '../components/genre_chip.dart';
import '../components/title_basic_info.dart';
import '../constants.dart';
import '../graphql/fragments/video_fragment.graphql.dart';
import '../graphql/queries/video.graphql.dart';
import '../router.dart';

class ShowVideoScreen extends StatefulWidget {
  const ShowVideoScreen({
    super.key,
    required this.video,
    required this.index,
    required this.currentPage,
    this.onUpdated,
    this.onSeeMore,
  });

  final int index;
  final int currentPage;
  final Fragment$VideoFragment video;
  final void Function()? onUpdated;
  final void Function()? onSeeMore;

  @override
  createState() => _ShowVideoScreenState();
}

class _ShowVideoScreenState extends State<ShowVideoScreen> with RouteAware {
  VideoPlayerController? _videoPlayerController;

  bool get _isReady => _videoPlayerController?.value.isInitialized ?? false;
  bool get _isPlaying => _videoPlayerController?.value.isPlaying ?? false;

  double get _thumbnailOpacity {
    if (_isReady) {
      return 0.0;
    } else {
      return 1.0;
    }
  }

  Future<void> _play() async {
    if (!_isReady) {
      _videoPlayerController = VideoPlayerController.networkUrl(widget.video.url, viewType: VideoViewType.platformView)
        ..setLooping(true)
        ..addListener(() {
          if (mounted) {
            setState(() {});
          }
        })
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
    }

    await _videoPlayerController?.play();

    await Future.delayed(const Duration(seconds: 5));
  }

  Future<void> _pause() async {
    await _videoPlayerController?.pause();
  }

  Future<void> _stop() async {
    await _videoPlayerController?.pause();
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
    if (_videoPlayerController?.value.isInitialized == true) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget _getVideoWidget(Fragment$VideoFragment video, {void Function()? onUpdated}) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Stack(
          children: [
            Center(
              child: OverflowBox(maxWidth: double.infinity, maxHeight: screenSize.height, child: _getVideoPlayer()),
            ),
            video.title.posterImageUrl != null
                ? AnimatedOpacity(
                    opacity: _thumbnailOpacity,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      color: Colors.black,
                      width: screenSize.width,
                      height: screenSize.height,
                      child: Center(child: Image.network(video.title.posterImageUrl!.toString())),
                    ),
                  )
                : const SizedBox(),
            InkWell(
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
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionButtons(
              direction: Axis.vertical,
              titleId: video.title.id,
              userTitleTie: video.title.currentUserTie,
              videoId: widget.video.id,
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
                  video.title.name,
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
                      child: TitleBasicInfo(
                        isCentered: false,
                        releasedOn: video.title.releasedOn,
                        directorName: widget.video.title.crew.nodes.firstOrNull?.person.name,
                        runtime: video.title.runtime,
                        mediaType: video.title.mediaType,
                        extraChips: video.title.genres.nodes
                            .map((genre) => Flexible(child: GenreChip(name: genre.name)))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8, width: 8),
                    Expanded(
                      flex: isPortrait ? 0 : 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (widget.onSeeMore != null) {
                              widget.onSeeMore?.call();
                              return;
                            }

                            context.goNamed(
                              routeNameShowTitle,
                              pathParameters: {keyTitleId: video.title.id},
                              queryParameters: {keyVideoId: video.id},
                            );
                          },
                          style: FilledButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            backgroundColor: const Color(0xffFC7753),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('More details'),
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

  @override
  void initState() {
    super.initState();

    if (widget.index == 0) {
      _play();
    }
  }

  @override
  didUpdateWidget(ShowVideoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index == widget.currentPage) {
      _play();
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
    if (widget.index == widget.currentPage) {
      _play();
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
    return Query$Video$Widget(
      options: Options$Query$Video(variables: Variables$Query$Video(id: widget.video.id)),
      builder: (result, {fetchMore, refetch}) {
        final video = result.parsedData?.video ?? widget.video;

        return _getVideoWidget(video, onUpdated: () => refetch?.call());
      },
    );
  }
}
