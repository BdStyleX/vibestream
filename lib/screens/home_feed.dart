import 'package:flutter/material.dart';
import '../models.dart';
import '../services/post_service.dart';
import '../theme.dart';
import '../widgets/post_card.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});
  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final svc = PostService();
  bool forYou = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: _topBar()),
      Expanded(
        child: !forYou
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Following feed is coming soon.\nFor now, enjoy the For You feed.',
                      textAlign: TextAlign.center, style: TextStyle(color: VS.muted)),
                ),
              )
            : StreamBuilder<Set<String>>(
                stream: svc.blocked(),
                builder: (_, bs) => StreamBuilder<List<Post>>(
                  stream: svc.feed(),
                  builder: (_, snap) {
                    if (snap.hasError) {
                      return const Center(child: Text('Could not load the feed.'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final blocked = bs.data ?? {};
                    final list = snap.data!.where((p) => !blocked.contains(p.uid)).toList();
                    if (list.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No posts yet. Tap + to share the first one.',
                              textAlign: TextAlign.center, style: TextStyle(color: VS.muted)),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (_, i) => PostCard(post: list[i], svc: svc),
                    );
                  },
                ),
              ),
      ),
    ]);
  }

  Widget _topBar() {
    Widget pill(String label, bool on, VoidCallback tap) => GestureDetector(
          onTap: tap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: on ? VS.gradient : null, borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: on ? FontWeight.w600 : FontWeight.w500)),
          ),
        );
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1F), borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          pill('Following', !forYou, () => setState(() => forYou = false)),
          pill('For You', forYou, () => setState(() => forYou = true)),
        ]),
      ),
    ]);
  }
}
