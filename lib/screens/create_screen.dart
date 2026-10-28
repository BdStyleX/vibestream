import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';
import '../theme.dart';

class CreateScreen extends StatefulWidget {
  final VoidCallback onPosted;
  const CreateScreen({super.key, required this.onPosted});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final svc = PostService();
  final picker = ImagePicker();
  final caption = TextEditingController();
  final q = TextEditingController();
  final a = TextEditingController();
  final b = TextEditingController();
  XFile? media;
  bool isVideo = false, busy = false, poll = false;
  String? error;

  Future<void> _pick(bool video) async {
    final x = video
        ? await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60))
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
    if (x == null) return;
    if (await x.length() > 50 * 1024 * 1024) {
      setState(() => error = 'File is too large (max 50 MB).');
      return;
    }
    setState(() {
      media = x;
      isVideo = video;
      error = null;
    });
  }

  Future<void> _post() async {
    if (caption.text.trim().isEmpty && media == null) {
      setState(() => error = 'Write something or add a photo or video.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await svc.createPost(
        caption: caption.text,
        media: media,
        isVideo: isVideo,
        pollQuestion: poll ? q.text : null,
        optionA: poll ? a.text : null,
        optionB: poll ? b.text : null,
      );
      caption.clear();
      q.clear();
      a.clear();
      b.clear();
      setState(() {
        media = null;
        poll = false;
      });
      widget.onPosted();
    } catch (_) {
      if (mounted) setState(() => error = 'Could not post. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: VS.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 120), children: [
      const Text('Create', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 14),
      TextField(controller: caption, maxLines: 4, maxLength: 2000, decoration: _dec('What is your vibe?')),
      const SizedBox(height: 8),
      Row(children: [
        OutlinedButton.icon(onPressed: busy ? null : () => _pick(false), icon: const Icon(Icons.image_outlined), label: const Text('Photo')),
        const SizedBox(width: 8),
        OutlinedButton.icon(onPressed: busy ? null : () => _pick(true), icon: const Icon(Icons.videocam_outlined), label: const Text('VibeSnip')),
      ]),
      if (media != null) ...[
        const SizedBox(height: 10),
        Row(children: [
          Icon(isVideo ? Icons.videocam : Icons.image, color: VS.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(isVideo ? 'Video selected' : 'Photo selected')),
          IconButton(tooltip: 'Remove', onPressed: () => setState(() => media = null), icon: const Icon(Icons.close)),
        ]),
      ],
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Add a Remix Poll'),
        value: poll,
        onChanged: (v) => setState(() => poll = v),
      ),
      if (poll) ...[
        TextField(controller: q, decoration: _dec('Question')),
        const SizedBox(height: 8),
        TextField(controller: a, decoration: _dec('Option A')),
        const SizedBox(height: 8),
        TextField(controller: b, decoration: _dec('Option B')),
      ],
      if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Color(0xFFFF8A8A)))),
      const SizedBox(height: 16),
      SizedBox(
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: VS.gradient, borderRadius: BorderRadius.circular(14)),
          child: TextButton(
            onPressed: busy ? null : _post,
            child: busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    ]);
  }
}
