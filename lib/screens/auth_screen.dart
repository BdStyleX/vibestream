import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool signup = false, busy = false;
  String? error;

  Future<void> _submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (signup) {
        if (_name.text.trim().isEmpty) throw 'Please enter a display name.';
        await _auth.signUp(_name.text, _email.text, _pass.text);
      } else {
        await _auth.signIn(_email.text, _pass.text);
      }
    } catch (e) {
      if (mounted) setState(() => error = e is String ? e : AuthService.friendly(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _forgot() async {
    if (_email.text.trim().isEmpty) {
      setState(() => error = 'Enter your email first.');
      return;
    }
    try {
      await _auth.resetPassword(_email.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
      }
    } catch (e) {
      setState(() => error = AuthService.friendly(e));
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Center(
                  child: ShaderMask(
                    shaderCallback: (r) => VS.gradient.createShader(r),
                    child: const Icon(Icons.all_inclusive, size: 72, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text(signup ? 'Create your account' : 'Welcome back', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600))),
                const SizedBox(height: 24),
                if (signup) ...[TextField(controller: _name, decoration: _dec('Display name')), const SizedBox(height: 12)],
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _dec('Email')),
                const SizedBox(height: 12),
                TextField(controller: _pass, obscureText: true, decoration: _dec('Password')),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: VS.gradient, borderRadius: BorderRadius.circular(14)),
                    child: TextButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(signup ? 'Sign up' : 'Log in', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    signup = !signup;
                    error = null;
                  }),
                  child: Text(signup ? 'I already have an account' : 'Create a new account'),
                ),
                if (!signup) TextButton(onPressed: _forgot, child: const Text('Forgot password?')),
                if (signup)
                  const Text(
                    'By signing up you agree to our Terms and Privacy Policy, and to not post harmful or illegal content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: VS.muted),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
