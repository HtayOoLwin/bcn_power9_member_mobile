import 'package:flutter/material.dart';

void main() => runApp(const Power9MemberApp());

class Power9MemberApp extends StatelessWidget {
  const Power9MemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POWER 9 Reward App',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
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

  static const green = Color(0xFF008B68);
  static const darkGreen = Color(0xFF004E45);
  static const lime = Color(0xFF9EE322);

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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final heroHeight = h * .48;
            final panelTop = h * .43;
            return SizedBox(
              height: h,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroHeight,
                    child: _hero(),
                  ),
                  Positioned(
                    top: panelTop,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _loginPanel(h),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _hero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/power9_station.png',
          fit: BoxFit.cover,
          alignment: const Alignment(0, .15),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Color(0x3300182A), Colors.transparent],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Align(
            alignment: const Alignment(0, -.83),
            child: _brand(),
          ),
        ),
      ],
    );
  }

  Widget _brand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              shadows: [Shadow(color: Color(0x66000000), blurRadius: 5)],
            ),
            children: [
              TextSpan(text: 'POWER ', style: TextStyle(color: Colors.white)),
              TextSpan(text: '9', style: TextStyle(color: lime)),
            ],
          ),
        ),
        const Text(
          'Reward App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            height: .95,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Color(0x66000000), blurRadius: 5)],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fuel Rewards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Color(0x77000000), blurRadius: 5)],
          ),
        ),
        const Text(
          'Brighter Journeys',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            shadows: [Shadow(color: Color(0x77000000), blurRadius: 5)],
          ),
        ),
      ],
    );
  }

  Widget _loginPanel(double screenHeight) {
    final compact = screenHeight < 760;
    final pad = compact ? 18.0 : 22.0;
    return Container(
      padding: EdgeInsets.fromLTRB(24, pad, 24, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x18000000), blurRadius: 18, offset: Offset(0, -3)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(
                color: darkGreen,
                fontSize: compact ? 24 : 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: compact ? 3 : 5),
            Text(
              'Login to your account and continue\nyour POWER 9 rewards journey.',
              style: TextStyle(
                color: const Color(0xFF748294),
                fontSize: compact ? 12 : 13,
                height: 1.3,
              ),
            ),
            SizedBox(height: compact ? 10 : 14),
            SizedBox(
              height: compact ? 48 : 52,
              child: TextFormField(
                key: const Key('login_identifier'),
                controller: _userController,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  'Email address or phone number',
                  Icons.mail_outline_rounded,
                  compact,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter your email or phone number.'
                    : null,
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            SizedBox(
              height: compact ? 48 : 52,
              child: TextFormField(
                key: const Key('login_password'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                decoration: _decoration(
                  'Password',
                  Icons.lock_outline_rounded,
                  compact,
                  suffix: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: darkGreen,
                      size: 22,
                    ),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter your password.'
                    : null,
              ),
            ),
            SizedBox(
              height: compact ? 34 : 38,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('forgot_password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: green,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: compact ? 44 : 48,
              child: FilledButton(
                key: const Key('login_button'),
                onPressed: _login,
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: compact ? 15 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 8 : 11),
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFFD4DDE0))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Color(0xFF788695),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFFD4DDE0))),
              ],
            ),
            SizedBox(height: compact ? 8 : 11),
            SizedBox(
              height: compact ? 43 : 47,
              child: OutlinedButton.icon(
                key: const Key('create_account_button'),
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                label: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF748092), fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Register now.',
                        style: TextStyle(
                          color: green,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(
    String hint,
    IconData icon,
    bool compact, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF8997A7),
        fontSize: compact ? 12 : 13,
      ),
      prefixIcon: Icon(icon, color: darkGreen, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFCFDFD),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: _border(const Color(0xFFD4DDE0)),
      enabledBorder: _border(const Color(0xFFD4DDE0)),
      focusedBorder: _border(green, width: 1.5),
      errorBorder: _border(Colors.redAccent),
      focusedErrorBorder: _border(Colors.redAccent),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
