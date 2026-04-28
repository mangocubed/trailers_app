import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'yt_player.dart';
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

class _VideoPlayerDialog extends StatelessWidget {
  const _VideoPlayerDialog({required this.video});

  final Fragment$VideoFragment video;

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
            Container(
              constraints: BoxConstraints(maxWidth: screenSize.width - 24, maxHeight: screenSize.height - 64),
              child: YTPlayer(id: video.sourceKey),
            ),
            Positioned(
              top: 8,
              right: 8,
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
