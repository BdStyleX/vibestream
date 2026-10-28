import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models.dart';

class PostService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  User get _me => FirebaseAuth.instance.currentUser!;
  String get myUid => _me.uid;

  CollectionReference<Map<String, dynamic>> get _posts => _db.collection('posts');

  Stream<List<Post>> feed() => _posts
      .orderBy('createdAt', descending: true)
      .limit(40)
      .snapshots()
      .map((s) => s.docs.map(Post.fromDoc).toList());

  /// Videos only (VibeSnips). Sorted on the device so no extra index is needed.
  Stream<List<Post>> videos() => _posts
      .where('mediaType', isEqualTo: 'video')
      .limit(40)
      .snapshots()
      .map((s) => _sorted(s.docs.map(Post.fromDoc).toList()));

  Stream<List<Post>> byUser(String uid) => _posts
      .where('uid', isEqualTo: uid)
      .limit(60)
      .snapshots()
      .map((s) => _sorted(s.docs.map(Post.fromDoc).toList()));

  List<Post> _sorted(List<Post> l) {
    l.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return l;
  }

  Future<void> createPost({
    required String caption,
    XFile? media,
    bool isVideo = false,
    String? pollQuestion,
    String? optionA,
    String? optionB,
  }) async {
    final ref = _posts.doc();
    String? url;
    if (media != null) {
      final name = media.name.toLowerCase();
      final ext = isVideo ? (name.endsWith('.mov') ? 'mov' : 'mp4') : 'jpg';
      final type = media.mimeType ?? (isVideo ? 'video/mp4' : 'image/jpeg');
      final sref = _storage.ref('posts/${_me.uid}/${ref.id}.$ext');
      await sref.putData(await media.readAsBytes(), SettableMetadata(contentType: type));
      url = await sref.getDownloadURL();
    }
    final hasPoll = (pollQuestion ?? '').trim().isNotEmpty &&
        (optionA ?? '').trim().isNotEmpty &&
        (optionB ?? '').trim().isNotEmpty;
    await ref.set({
      'uid': _me.uid,
      'userName': _me.displayName ?? 'User',
      'caption': caption.trim(),
      if (url != null) 'mediaUrl': url,
      if (url != null) 'mediaType': isVideo ? 'video' : 'image',
      if (hasPoll) 'pollQuestion': pollQuestion!.trim(),
      if (hasPoll) 'optionA': optionA!.trim(),
      if (hasPoll) 'optionB': optionB!.trim(),
      'likeCount': 0,
      'votesA': 0,
      'votesB': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(Post p) async {
    await _posts.doc(p.id).delete();
    if (p.hasMedia) {
      try {
        await _storage.refFromURL(p.mediaUrl!).delete();
      } catch (_) {}
    }
  }

  // ---- likes ----
  Stream<bool> liked(String postId) =>
      _posts.doc(postId).collection('likes').doc(_me.uid).snapshots().map((d) => d.exists);

  Future<void> toggleLike(String postId) async {
    final postRef = _posts.doc(postId);
    final likeRef = postRef.collection('likes').doc(_me.uid);
    await _db.runTransaction((tx) async {
      final like = await tx.get(likeRef);
      if (like.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likeCount': FieldValue.increment(-1)});
      } else {
        tx.set(likeRef, {'at': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likeCount': FieldValue.increment(1)});
      }
    });
  }

  // ---- Remix Poll ----
  Stream<String?> myVote(String postId) => _posts
      .doc(postId)
      .collection('votes')
      .doc(_me.uid)
      .snapshots()
      .map((d) => d.data()?['choice'] as String?);

  Future<void> vote(String postId, String choice) async {
    final postRef = _posts.doc(postId);
    final voteRef = postRef.collection('votes').doc(_me.uid);
    await _db.runTransaction((tx) async {
      final v = await tx.get(voteRef);
      if (v.exists) return;
      tx.set(voteRef, {'choice': choice});
      tx.update(postRef, {choice == 'a' ? 'votesA' : 'votesB': FieldValue.increment(1)});
    });
  }

  // ---- safety: report + block ----
  Future<void> report(Post p, String reason) => _db.collection('reports').add({
        'postId': p.id,
        'postOwnerUid': p.uid,
        'reporterUid': _me.uid,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Stream<Set<String>> blocked() => _db
      .collection('users')
      .doc(_me.uid)
      .collection('blocked')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  Future<void> block(String uid) => _db
      .collection('users')
      .doc(_me.uid)
      .collection('blocked')
      .doc(uid)
      .set({'at': FieldValue.serverTimestamp()});
}
