import 'package:flutter/material.dart';
import '../models.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../theme.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const tabs = ['Posts', 'VibeSnips', 'Live Pods', 'Vault'];
  final auth = AuthService();
  final svc = PostService();
  String tab = 'Posts';

  @override
  Widget build(BuildContext context) {
    final u = auth.user!;
    final name = (u.displayName ?? 'User');
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
      children: [
        Row(children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: VS.gradient),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3A1C6E),
                border: Border.all(color: VS.bg, width: 3),
              ),
              child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(u.email ?? '', style: const TextStyle(fontSize: 13, color: VS.muted)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final t in tabs)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => tab = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: tab == t ? VS.gradient : null, borderRadius: BorderRadius.circular(999)),
                    child: Text(t, style: TextStyle(fontSize: 13, fontWeight: tab == t ? FontWeight.w600 : FontWeight.w500)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        if (tab == 'Posts' || tab == 'VibeSnips') _myPosts(u.uid, videosOnly: tab == 'VibeSnips') else _soon(tab),
        const SizedBox(height: 24),
        const Divider(color: VS.border),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: const Text('Log out'),
          onTap: auth.signOut,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_outline, color: Color(0xFFFF8A8A)),
          title: const Text('Delete my account', style: TextStyle(color: Color(0xFFFF8A8A))),
          onTap: _deleteAccount,
        ),
      ],
    );
  }

  Widget _soon(String t) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('$t is coming soon.', textAlign: TextAlign.center, style: const TextStyle(color: VS.muted)),
      );

  Widget _myPosts(String uid, {required bool videosOnly}) => StreamBuilder<List<Post>>(
        stream: svc.byUser(uid),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!.where((p) => !videosOnly || p.isVideo).toList();
          if (list.isEmpty) return _soon('Nothing here yet.\nYour posts');
          return Column(children: [
            for (final p in list) ...[PostCard(post: p, svc: svc), const SizedBox(height: 14)],
          ]);
        },
      );

  Future<void> _deleteAccount() async {
    final pass = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('This permanently deletes your account and all your posts. Enter your password to confirm.'),
          TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await auth.deleteAccount(pass.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthService.friendly(e))));
      }
    }
  }
}
