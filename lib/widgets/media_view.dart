import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme.dart';

/// Shows a network image, or a tap-to-play video.
/// [fill] = cover the whole parent (VibeSnips); [active] = autoplay when true.
class MediaView extends StatefulWidget {
  final String url;
  final bool isVideo;
  final bool fill;
  final bool active;
  const MediaView({super.key, required this.url, required this.isVideo, this.fill = false, this.active = false});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  VideoPlayerController? _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..setLooping(true)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
          if (widget.active) _c!.play();
        });
    }
  }

  @override
  void didUpdateWidget(MediaView old) {
    super.didUpdateWidget(old);
    if (_ready && widget.active != old.active) {
      widget.active ? _c!.play() : _c!.pause();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVideo) {
      return Image.network(
        widget.url,
        width: double.infinity,
        height: widget.fill ? double.infinity : 260,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(height: 120, child: Center(child: Icon(Icons.broken_image_outlined))),
        loadingBuilder: (_, child, p) => p == null ? child : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      );
    }
    if (!_ready) {
      return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
    }
    final c = _c!;
    final video = widget.fill
        ? FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
          )
        : AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c));
    return GestureDetector(
      onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
      child: Stack(alignment: Alignment.center, children: [
        video,
        if (!c.value.isPlaying)
          const Icon(Icons.play_circle_fill, size: 64, color: VS.text),
      ]),
    );
  }
}
