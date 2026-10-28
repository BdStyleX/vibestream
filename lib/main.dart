import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/create_screen.dart';
import 'screens/home_feed.dart';
import 'screens/profile.dart';
import 'screens/vibesnips.dart';
import 'theme.dart';
import 'widgets/glass_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VibeStreamApp());
}

class VibeStreamApp extends StatelessWidget {
  const VibeStreamApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'VibeStream',
        debugShowCheckedModeBanner: false,
        theme: VS.theme(),
        home: const Splash(),
      );
}

/// Pulsing logo, then fades into the auth gate.
class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthGate(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.08).animate(_c),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ShaderMask(
                shaderCallback: (r) => VS.gradient.createShader(r),
                child: const Icon(Icons.all_inclusive, size: 110, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (r) => VS.gradient.createShader(r),
                child: const Text('VibeStream', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
          ),
        ),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snap.hasData ? const Shell() : const AuthScreen();
        },
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  Widget _body() {
    switch (index) {
      case 0:
        return const HomeFeed();
      case 1:
        return const VibeSnips();
      case 2:
        return CreateScreen(onPosted: () => setState(() => index = 0));
      case 3:
        return const Center(child: Text('No notifications yet.', style: TextStyle(color: VS.muted)));
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        body: SafeArea(bottom: false, child: _body()),
        bottomNavigationBar: GlassNav(index: index, onTap: (i) => setState(() => index = i)),
      );
}
