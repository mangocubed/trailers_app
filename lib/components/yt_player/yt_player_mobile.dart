import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YTPlayer extends StatefulWidget {
  const YTPlayer({super.key, required this.id});

  final String id;

  @override
  createState() => _YTPlayerState();
}

class _YTPlayerState extends State<YTPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(initialVideoId: widget.id, flags: YoutubePlayerFlags(autoPlay: true));
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller);
  }
}
