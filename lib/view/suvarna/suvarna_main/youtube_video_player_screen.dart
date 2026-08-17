import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_app_bar.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  const YoutubeVideoPlayerScreen({super.key});

  @override
  State<YoutubeVideoPlayerScreen> createState() => _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  late YoutubePlayerController _playerController;
  late String videoId;
  late String title;
  late String desc;

  @override
  void initState() {
    super.initState();
    // Retrieve arguments
    final args = Get.arguments as Map<String, String>;
    videoId = args['id'] ?? '';
    title = args['title'] ?? 'YouTube Video';
    desc = args['desc'] ?? '';

    _playerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        enableCaption: false,
        showLiveFullscreenButton: false,
      ),
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: const CustomAppBar(
          title: "Video Player",
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video player aspect box
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _playerController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primaryMaroon,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.primaryMaroon,
                  handleColor: AppColors.primaryGold,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white12,
                ),
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(
                    isExpanded: true,
                    colors: const ProgressBarColors(
                      playedColor: AppColors.primaryMaroon,
                      handleColor: AppColors.primaryGold,
                      bufferedColor: Colors.white30,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  RemainingDuration(),
                ],
              ),
            ),
            // Info panel in App Theme
            Expanded(
              child: Container(
                color: AppColors.backgroundPrimary,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMaroon.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryMaroon.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        'OFFICIAL TUTORIAL',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryMaroon,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        color: AppColors.primaryMaroon,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          desc,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
