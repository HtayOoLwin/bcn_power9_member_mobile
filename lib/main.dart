import 'package:flutter/material.dart';

void main() => runApp(const Power9MemberApp());

class Power9MemberApp extends StatelessWidget {
  const Power9MemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POWER 9 Reward App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008B68)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const _green = Color(0xFF008B68);
  static const _darkGreen = Color(0xFF004E45);
  static const _lime = Color(0xFF9EE322);
  static const _navy = Color(0xFF07152B);

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login API will be connected next.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildBrand(),
                      const SizedBox(height: 8),
                      _buildStationHero(),
                      const SizedBox(height: 12),
                      _buildLoginForm(),
                      const Spacer(),
                      const SizedBox(height: 10),
                      _buildRegisterFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
            children: [
              TextSpan(text: 'POWER ', style: TextStyle(color: _darkGreen)),
              TextSpan(text: '9', style: TextStyle(color: _lime)),
            ],
          ),
        ),
        const Text(
          'Reward App',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 18,
            height: 0.95,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Fuel Rewards',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          'Brighter Journeys',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 9,
            letterSpacing: .3,
          ),
        ),
      ],
    );
  }

  Widget _buildStationHero() {
    return Container(
      height: 130,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B5F65), Color(0xFF083B45)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            right: -35,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 18,
            right: 18,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0B6D54),
                borderRadius: BorderRadius.circular(7),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(height: 7, color: _lime),
                  ),
                  const Positioned(
                    left: 13,
                    top: 13,
                    child: Text(
                      'POWER 9',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 13,
                    right: 13,
                    bottom: 9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (_) => Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FFF9),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 18,
            top: 14,
            child: Text(
              'More Points.\nFurther Journeys.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              color: _navy,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Login to your account and continue\nyour POWER 9 rewards journey.',
            style: TextStyle(
              color: Color(0xFF68778C),
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            key: const Key('login_identifier'),
            controller: _userController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Email address or phone number',
              icon: Icons.mail_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email or phone number.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('login_password'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            decoration: _inputDecoration(
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                  color: const Color(0xFF0B3553),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 42,
            child: FilledButton(
              key: const Key('login_button'),
              onPressed: _login,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              key: const Key('forgot_password'),
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFD9E1E5))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Color(0xFF7C8996),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFD9E1E5))),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              key: const Key('create_account_button'),
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
              label: const Text(
                'Create Account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _green, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Color(0xFF748092), fontSize: 11),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Register now.',
            style: TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8B99A8), fontSize: 12),
      prefixIcon: Icon(icon, size: 21, color: const Color(0xFF173C5A)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7E1E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7E1E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
