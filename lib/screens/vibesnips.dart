import 'package:flutter/material.dart';
import '../models.dart';
import '../services/post_service.dart';
import '../theme.dart';
import '../widgets/media_view.dart';

/// Full-screen vertical pager of real video posts.
class VibeSnips extends StatefulWidget {
  const VibeSnips({super.key});
  @override
  State<VibeSnips> createState() => _VibeSnipsState();
}

class _VibeSnipsState extends State<VibeSnips> {
  final svc = PostService();
  int current = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<String>>(
      stream: svc.blocked(),
      builder: (_, bs) => StreamBuilder<List<Post>>(
        stream: svc.videos(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final blocked = bs.data ?? {};
          final list = snap.data!.where((p) => !blocked.contains(p.uid)).toList();
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No VibeSnips yet. Tap + and upload a short video.',
                    textAlign: TextAlign.center, style: TextStyle(color: VS.muted)),
              ),
            );
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: list.length,
            onPageChanged: (i) => setState(() => current = i),
            itemBuilder: (_, i) {
              final p = list[i];
              return Stack(fit: StackFit.expand, children: [
                MediaView(key: ValueKey(p.id), url: p.mediaUrl!, isVideo: true, fill: true, active: i == current),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xB3000000)],
                      stops: [0.55, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 80,
                  bottom: 110,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('@${p.userName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (p.caption.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(p.caption, style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ]),
                ),
                Positioned(
                  right: 8,
                  bottom: 110,
                  child: StreamBuilder<bool>(
                    stream: svc.liked(p.id),
                    builder: (_, ls) {
                      final on = ls.data ?? false;
                      return Column(children: [
                        IconButton(
                          tooltip: 'Like',
                          onPressed: () => svc.toggleLike(p.id),
                          icon: Icon(on ? Icons.favorite : Icons.favorite_border, size: 30, color: on ? VS.pink : Colors.white),
                        ),
                        Text('${p.likeCount}', style: const TextStyle(fontSize: 12)),
                      ]);
                    },
                  ),
                ),
              ]);
            },
          );
        },
      ),
    );
  }
}
