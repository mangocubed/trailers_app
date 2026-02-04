import 'package:flutter/material.dart';
import 'package:video_player_hdr/video_player_hdr.dart';

import '../router.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({super.key, required this.videoUrl, this.thumbnailImageUrl, this.onTogglePlayPause});

  final Uri videoUrl;
  final Uri? thumbnailImageUrl;
  final Function(bool isPlaying)? onTogglePlayPause;

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> with RouteAware {
  VideoPlayerHdrController? _videoPlayerController;

  bool get _isPlaying => _thumbnailOpacity == 1.0 || (_videoPlayerController?.value.isPlaying ?? true);

  _pause() {
    _videoPlayerController?.pause();

    widget.onTogglePlayPause?.call(false);
  }

  _play() {
    _videoPlayerController?.play();

    widget.onTogglePlayPause?.call(true);
  }

  _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  double get _thumbnailOpacity {
    final isReady = _videoPlayerController?.value.isInitialized ?? false;

    if (isReady) {
      return 0.0;
    } else {
      return 1.0;
    }
  }

  Widget _getVideoPlayer() {
    if (_videoPlayerController?.value.isInitialized == true) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayerHdr(_videoPlayerController!),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  @override
  void initState() {
    super.initState();

    _videoPlayerController ??= VideoPlayerHdrController.networkUrl(widget.videoUrl)
      ..setLooping(true)
      ..addListener(() {
        setState(() {});
      })
      ..initialize().then((_) {
        setState(() {});
      })
      ..play();
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
    _pause();
  }

  @override
  void didPopNext() {
    _play();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();

    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Center(
          child: OverflowBox(maxWidth: double.infinity, maxHeight: screenSize.height, child: _getVideoPlayer()),
        ),
        widget.thumbnailImageUrl != null
            ? AnimatedOpacity(
                opacity: _thumbnailOpacity,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  color: Colors.black,
                  width: screenSize.width,
                  height: screenSize.height,
                  child: Center(child: Image.network(widget.thumbnailImageUrl!.toString())),
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
              child: const Center(child: Icon(Icons.pause_rounded, color: Colors.grey, size: 128)),
            ),
          ),
        ),
      ],
    );
  }
}
