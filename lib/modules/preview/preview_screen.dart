import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fr_demo/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';

import '../../config/routes.dart';
import '../../utils/app_utils.dart';
import '../components/progress_bar/progress_view.dart';
import '../home/home_controller.dart';

String filePath = '';
String fileName = 'Preview';
bool isVideo = false;
bool isNetworkImage = false;
bool isNetworkVideo = false;
bool isVideoPlayerInit = false;

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _videoController;
  HomeController homeController = Get.find();

  @override
  void initState() {
    var arguments = Get.arguments;
    filePath = arguments['filePath'].toString();
    String name = arguments['name'].toString();
    if (filePath.isNotEmpty) {
      if (name.isNotEmpty && name.contains(':')) {
        final names = name.split(":");
        filePath = names.last;
        filePath = AppConstants.imageBaseUrl + filePath;
        isNetworkImage = true;
      } else {
        isNetworkImage = false;
        fileName = filePath.split('/').last;
      }
      isVideo = filePath.endsWith('.mp4');
      if (isVideo) {
        isNetworkVideo = AppUtils.isNetworkFile(filePath);
        initVideoPlayer();
      } else {
        isNetworkImage = AppUtils.isNetworkFile(filePath);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: Center(
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        child: const Text('Go to all captures'),
                        onPressed: () => Get.offAllNamed(Routes.home)),
                    !AppUtils.isNetworkFile(filePath)
                        ? ElevatedButton(
                            child: const Text('Upload'),
                            onPressed: () => startUpload(filePath)
                            //_showVideoTypeDialog(filePath, context),
                            )
                        : Container(),
                  ],
                ),
                Expanded(
                  child: Container(
                    child: filePath.isNotEmpty
                        ? isVideo
                            ? loadVideoPlayer(filePath, context)
                            : isNetworkImage
                                ? CachedNetworkImage(
                                    imageUrl: filePath,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    // ignore: prefer_const_literals_to_create_immutables
                                    httpHeaders: {
                                      "tenantUid": "test",
                                      "tuid": "test",
                                      "Authorization": "Basic YWRtaW46YWRtaW4="
                                    },
                                  )
                                : Image.file(File(filePath))
                        : Image.asset(
                            'assets/images/person_preview.png',
                            width: 300,
                            height: 200,
                          ),
                  ),
                ),
              ],
            ),
            const ProgressView()
          ],
        ),
      ),
    );
  }

  Future<void> startUpload(String filePath) async {
    final isSuccess = await homeController.uploadFile(
      filePath,
      AppUtils.position,
    );
    if (isSuccess) {
      deleteLocalFile(filePath);
      Get.offAllNamed(Routes.home);
    }
  }

  void deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
    } catch (e) {
      e.printError();
    }
  }

  void initVideoPlayer() {
    isVideoPlayerInit = true;
    if (isNetworkVideo) {
      debugPrint("Network video");
      _videoController = VideoPlayerController.network(filePath);
    } else {
      _videoController = VideoPlayerController.file(File(filePath),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    }
    _videoController.addListener(() {
      setState(() {});
    });
    _videoController.setLooping(false);
    _videoController.initialize().then((_) => setState(() {
          _videoController.play();
        }));
  }

  @override
  void dispose() {
    if (isVideoPlayerInit) {
      _videoController.dispose();
    }
    super.dispose();
  }

  loadVideoPlayer(String filePath, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_videoController),
            ClosedCaption(text: _videoController.value.caption.text),
            _ControlsOverlay(controller: _videoController),
            VideoProgressIndicator(_videoController, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
