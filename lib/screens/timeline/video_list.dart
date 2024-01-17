import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideosList extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;

  VideosList(
      {Key? key, required this.videoPlayerController, required this.looping})
      : super(key: key);

  @override
  _VideosListState createState() => _VideosListState();
}

class _VideosListState extends State<VideosList> {
  late ChewieController videosController;

  @override
  void initState() {
    super.initState();

    videosController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 3/2,
      autoInitialize: true,
      looping: widget.looping,
      showOptions: false,
      autoPlay: false,
      //placeholder: Icon(Icons.play_arrow),
      allowMuting: true,
      allowFullScreen: true,
      draggableProgressBar: true,
      fullScreenByDefault: false,
      errorBuilder: (context, errorMessage) {
        return Center(child: Text(errorMessage)
        );
      },
    );
  }

  Widget progressBar() {
    return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Chewie(
        controller: videosController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    videosController.dispose();
  }
}