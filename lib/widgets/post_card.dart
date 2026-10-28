import 'package:flutter/material.dart';
import '../models.dart';
import '../services/post_service.dart';
import '../theme.dart';
import 'media_view.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final PostService svc;
  const PostCard({super.key, required this.post, required this.svc});

  bool get _mine => post.uid == svc.myUid;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VS.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VS.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF3A1C6E),
            child: Text(post.userName.isEmpty ? '?' : post.userName[0].toUpperCase()),
          ),
          title: Text(post.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(ago(post.createdAt), style: const TextStyle(fontSize: 11, color: VS.muted)),
          trailing: PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_horiz, color: VS.muted),
            onSelected: (v) => _menu(context, v),
            itemBuilder: (_) => [
              if (_mine) const PopupMenuItem(value: 'delete', child: Text('Delete post')),
              if (!_mine) const PopupMenuItem(value: 'report', child: Text('Report post')),
              if (!_mine) const PopupMenuItem(value: 'block', child: Text('Block this user')),
            ],
          ),
        ),
        if (post.hasMedia) MediaView(url: post.mediaUrl!, isVideo: post.isVideo),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (post.caption.isNotEmpty) Text(post.caption, style: const TextStyle(fontSize: 14, height: 1.5)),
            if (post.hasPoll) ...[const SizedBox(height: 10), _poll()],
            const SizedBox(height: 4),
            Row(children: [
              StreamBuilder<bool>(
                stream: svc.liked(post.id),
                builder: (_, s) {
                  final on = s.data ?? false;
                  return TextButton.icon(
                    onPressed: () => svc.toggleLike(post.id),
                    icon: Icon(on ? Icons.favorite : Icons.favorite_border, color: on ? VS.pink : VS.muted),
                    label: Text('${post.likeCount}', style: TextStyle(color: on ? VS.pink : VS.muted)),
                  );
                },
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _poll() {
    final total = post.votesA + post.votesB;
    String pct(int v) => total == 0 ? '0%' : '${(v * 100 / total).round()}%';
    return StreamBuilder<String?>(
      stream: svc.myVote(post.id),
      builder: (_, s) {
        final voted = s.data;
        Widget option(String key, String label, int votes) {
          final sel = voted == key;
          return GestureDetector(
            onTap: voted == null ? () => svc.vote(post.id, key) : null,
            child: Container(
              height: 44,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? const Color(0x2400D2FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? VS.blue : const Color(0xFF2F2F3A)),
              ),
              child: Row(children: [
                Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
                if (voted != null) Text(pct(votes), style: const TextStyle(fontSize: 13)),
              ]),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: VS.surface2, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Remix Poll', style: TextStyle(color: Color(0xFF7FE3FF), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(post.pollQuestion!, style: const TextStyle(fontSize: 13)),
            option('a', post.optionA!, post.votesA),
            option('b', post.optionB!, post.votesB),
          ]),
        );
      },
    );
  }

  Future<void> _menu(BuildContext context, String v) async {
    final messenger = ScaffoldMessenger.of(context);
    if (v == 'delete') {
      await svc.deletePost(post);
    } else if (v == 'block') {
      await svc.block(post.uid);
      messenger.showSnackBar(const SnackBar(content: Text('User blocked. Their posts are hidden.')));
    } else if (v == 'report') {
      final reason = await showDialog<String>(
        context: context,
        builder: (_) => SimpleDialog(
          title: const Text('Report this post'),
          children: [
            for (final r in ['Spam', 'Harassment or hate', 'Nudity or sexual content', 'Violence', 'Other'])
              SimpleDialogOption(onPressed: () => Navigator.pop(context, r), child: Text(r)),
          ],
        ),
      );
      if (reason != null) {
        await svc.report(post, reason);
        messenger.showSnackBar(const SnackBar(content: Text('Thanks. We will review this report.')));
      }
    }
  }
}
