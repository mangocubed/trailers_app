import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../constants.dart';
import '../graphql/fragments/video_fragment.graphql.dart';

Future<dynamic> showVideoDialog({required BuildContext context, required Fragment$VideoFragment video}) {
  return showDialog(
    context: context,
    fullscreenDialog: true,
    builder: (context) {
      return _VideoDialog(video: video);
    },
  );
}

class _VideoDialog extends StatefulWidget {
  const _VideoDialog({required this.video});

  final Fragment$VideoFragment video;

  @override
  createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  late VideoPlayerController _controller;

  Widget _getVideoPlayer() {
    final screenSize = MediaQuery.of(context).size;

    if (_controller.value.isInitialized == true) {
      return Container(
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
      );
    }

    return const CircularProgressIndicator();
  }

  @override
  void initState() {
    super.initState();

    final sourceUrl = widget.video.hlsUrl != null && !kIsWeb ? widget.video.hlsUrl! : widget.video.url;
    _controller = VideoPlayerController.networkUrl(sourceUrl, viewType: VideoViewType.platformView)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      })
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _getVideoPlayer(),
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
