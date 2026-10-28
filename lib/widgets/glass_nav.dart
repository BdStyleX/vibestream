import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class GlassNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const GlassNav({super.key, required this.index, required this.onTap});

  static const _icons = [
    Icons.home_outlined,
    Icons.play_circle_outline,
    null, // create button
    Icons.notifications_none,
    Icons.person_outline,
  ];
  static const _labels = ['Home', 'VibeSnips', 'Create', 'Notifications', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0x9E1E1E26),
              border: Border.all(color: const Color(0x1AFFFFFF)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < 5; i++)
                  Semantics(
                    label: _labels[i],
                    button: true,
                    child: InkResponse(
                      onTap: () => onTap(i),
                      child: i == 2
                          ? Container(
                              width: 52,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: VS.gradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: Color(0x998A2BE2), blurRadius: 16)],
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            )
                          : SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(_icons[i], color: index == i ? const Color(0xFFB57BFF) : VS.muted),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
