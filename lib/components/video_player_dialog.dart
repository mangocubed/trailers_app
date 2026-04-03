import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../constants.dart';
import '../graphql/fragments/video_fragment.graphql.dart';

Future<dynamic> showVideoPlayerDialog({required BuildContext context, required Fragment$VideoFragment video}) {
  return showDialog(
    context: context,
    fullscreenDialog: true,
    builder: (context) {
      return _VideoPlayerDialog(video: video);
    },
  );
}

class _VideoPlayerDialog extends StatefulWidget {
  const _VideoPlayerDialog({required this.video});

  final Fragment$VideoFragment video;

  @override
  createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late final VideoPlayerController _controller;

  Fragment$VideoFragment get _video => widget.video;

  Future<void> _initialize() async {
    final sourceUrl = _video.hlsUrl != null && !kIsWeb ? _video.hlsUrl! : _video.url;

    _controller = VideoPlayerController.networkUrl(sourceUrl, viewType: VideoViewType.platformView);

    await _controller.setLooping(true);
    await _controller.initialize();
    await _controller.play();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog.fullscreen(
      backgroundColor: colorTranslucent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.pop();
        },
        child: Stack(
          alignment: AlignmentGeometry.center,
          children: [
            Visibility(
              visible: _controller.value.isInitialized,
              replacement: const CircularProgressIndicator(),
              child: Container(
                constraints: BoxConstraints(maxWidth: screenSize.width - 24, maxHeight: screenSize.height - 24),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      VideoPlayer(_controller),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: SizedBox.expand(
                          child: Visibility(
                            visible: !_controller.value.isPlaying,
                            child: Center(child: Icon(Icons.pause_rounded, color: colorPlayIcon, size: 128)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: CloseButton(
                onPressed: () {
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
