import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SuvarnaMainController extends GetxController {
  // ─── YouTube ──────────────────────────────────────────────────────────────
  static const String _videoUrl =
      'https://youtu.be/8nyjzyAij9Q?si=0vHhB4NsyrL7lNl6';

  late YoutubePlayerController youtubeController;

  final RxBool isPlaying = false.obs;
  final RxBool isVideoReady = false.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initYoutube();
  }

  void _initYoutube() {
    final videoId = YoutubePlayer.convertUrlToId(_videoUrl) ?? '8nyjzyAij9Q';
    youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        enableCaption: false,
      ),
    );

    youtubeController.addListener(() {
      isPlaying.value = youtubeController.value.isPlaying;
      if (youtubeController.value.isReady && !isVideoReady.value) {
        isVideoReady.value = true;
      }
    });
  }

  void togglePlayPause() {
    if (youtubeController.value.isPlaying) {
      youtubeController.pause();
    } else {
      youtubeController.play();
    }
  }

  @override
  void onClose() {
    youtubeController.dispose();
    super.onClose();
  }
}
