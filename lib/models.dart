import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const placeholderGradients = [
  [Color(0xFF6A1FC2), Color(0xFF1B2A6B)],
  [Color(0xFF0F7A6B), Color(0xFF1B4B8F)],
  [Color(0xFFB1246F), Color(0xFF4B1B8F)],
  [Color(0xFF00A9D6), Color(0xFF4B1B8F)],
];

class Post {
  final String id, uid, userName, caption;
  final String? mediaUrl, mediaType, pollQuestion, optionA, optionB;
  final int likeCount, votesA, votesB;
  final DateTime? createdAt;

  const Post({
    required this.id,
    required this.uid,
    required this.userName,
    required this.caption,
    this.mediaUrl,
    this.mediaType,
    this.pollQuestion,
    this.optionA,
    this.optionB,
    this.likeCount = 0,
    this.votesA = 0,
    this.votesB = 0,
    this.createdAt,
  });

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Post(
      id: d.id,
      uid: (m['uid'] ?? '') as String,
      userName: (m['userName'] ?? 'User') as String,
      caption: (m['caption'] ?? '') as String,
      mediaUrl: m['mediaUrl'] as String?,
      mediaType: m['mediaType'] as String?,
      pollQuestion: m['pollQuestion'] as String?,
      optionA: m['optionA'] as String?,
      optionB: m['optionB'] as String?,
      likeCount: (m['likeCount'] ?? 0) as int,
      votesA: (m['votesA'] ?? 0) as int,
      votesB: (m['votesB'] ?? 0) as int,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isVideo => mediaType == 'video';
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get hasPoll =>
      (pollQuestion ?? '').isNotEmpty && (optionA ?? '').isNotEmpty && (optionB ?? '').isNotEmpty;
}

String ago(DateTime? t) {
  if (t == null) return 'now';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  return '${d.inDays}d';
}
