import 'package:flutter/material.dart';

import 'auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.authService,
    this.initialEmail = '',
  });

  final MemberAuthService authService;
  final String initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _deepGreen = Color(0xFF00563F);
  static const _fieldBorder = Color(0xFFD9E0DC);
  static const _mutedText = Color(0xFF6F7B75);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEmail.trim();
    _emailController = TextEditingController(
      text: initial.contains('@') ? initial : '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.authService.requestPasswordReset(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = result.success;
      _error = result.success ? null : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF173D32),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _sent ? _buildSuccess() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset_rounded, size: 62, color: _deepGreen),
          const SizedBox(height: 22),
          const Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF173D32),
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter your email address and we will send you a password reset link.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText, fontSize: 14.5, height: 1.45),
          ),
          const SizedBox(height: 30),
          const Text(
            'Email Address',
            style: TextStyle(
              color: Color(0xFF173D32),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('forgot_password_email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) {
              if (!_isLoading) _sendResetLink();
            },
            decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _fieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _deepGreen, width: 1.6),
              ),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
              if (!valid) return 'Please enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: _deepGreen, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We will send a password reset link to your registered email address.',
                    style: TextStyle(
                      color: Color(0xFF365B50),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              key: const Key('send_reset_link_button'),
              onPressed: _isLoading ? null : _sendResetLink,
              style: FilledButton.styleFrom(
                backgroundColor: _deepGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.send_rounded, color: _deepGreen, size: 82),
        const SizedBox(height: 28),
        const Text(
          'Password Reset Link Sent',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF173D32),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'We have sent a password reset link to\n' + _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _mutedText,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Please check your email and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedText, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 34),
        SizedBox(
          height: 52,
          child: FilledButton(
            key: const Key('forgot_password_back_to_login'),
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: _deepGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
