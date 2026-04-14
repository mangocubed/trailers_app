import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../graphql/fragments/video_fragment.graphql.dart';

class TitleVideoPlayer extends StatefulWidget {
  const TitleVideoPlayer({super.key, required this.video, required this.play, required this.onInitialize});

  final Fragment$VideoFragment video;
  final bool play;
  final Function() onInitialize;

  @override
  createState() => _TitleVideoPlayerState();
}

class _TitleVideoPlayerState extends State<TitleVideoPlayer> {
  late final VideoPlayerController _controller;

  Fragment$VideoFragment get _video => widget.video;

  Future<void> _play() async {
    final isInitialized = _controller.value.isInitialized;

    if (kIsWeb && !isInitialized) {
      await _controller.initialize();
    }

    await _controller.play();

    if (kIsWeb && !isInitialized && _controller.value.isInitialized) {
      widget.onInitialize();
    }
  }

  @override
  void initState() {
    super.initState();

    final sourceUrl = _video.hlsUrl != null && !kIsWeb ? _video.hlsUrl! : _video.url;

    _controller = VideoPlayerController.networkUrl(sourceUrl, viewType: VideoViewType.platformView)..setLooping(true);

    if (kIsWeb) {
      if (widget.play) {
        _play();
      }
    } else {
      _controller.initialize().then((_) {
        widget.onInitialize();

        if (widget.play) {
          _play();
        }
      });
    }
  }

  @override
  didUpdateWidget(TitleVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.play) {
      _play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _controller.value.isInitialized,
      replacement: const CircularProgressIndicator(),
      child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
    );
  }
}
