import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/action_buttons.dart';
import '../components/genre_chip.dart';
import '../components/title_basic_info.dart';
import '../components/custom_video_player.dart';
import '../constants.dart';
import '../graphql/fragments/video_fragment.graphql.dart';
import '../graphql/queries/video.graphql.dart';

class ShowVideoScreen extends StatefulWidget {
  const ShowVideoScreen({super.key, required this.video, this.onUpdated, this.onSeeMore});

  final Fragment$VideoFragment video;
  final void Function()? onUpdated;
  final void Function()? onSeeMore;

  @override
  createState() => _ShowVideoScreenState();
}

class _ShowVideoScreenState extends State<ShowVideoScreen> {
  bool _isPlaying = true;
  bool _infoIsVisible = true;

  void _toggleInfoVisibility(bool isPlaying) {
    if (!mounted) {
      return;
    }

    setState(() => _isPlaying = isPlaying);

    if (isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _infoIsVisible = !_isPlaying);
        }
      });
    } else {
      setState(() => _infoIsVisible = true);
    }
  }

  Widget _getVideoWidget(Fragment$VideoFragment video, {void Function()? onUpdated}) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Stack(
      children: [
        CustomVideoPlayer(
          videoUrl: video.url,
          thumbnailImageUrl: video.title.posterImageUrl,
          onTogglePlayPause: _toggleInfoVisibility,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionButtons(
              direction: Axis.vertical,
              titleId: video.title.id,
              isBookmarked: video.title.currentUserTie?.isBookmarked == true,
              isLiked: video.title.currentUserTie?.isLiked == true,
              isWatched: video.title.currentUserTie?.isWatched == true,
              onUpdated: () {
                onUpdated?.call();
                widget.onUpdated?.call();
              },
              videoId: widget.video.id,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !_infoIsVisible,
            child: AnimatedOpacity(
              opacity: _infoIsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
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
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _toggleInfoVisibility(true);

    super.initState();
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
