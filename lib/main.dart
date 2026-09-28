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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildHero(),
                      const SizedBox(height: 540),
                    ],
                  ),
                  Positioned(
                    top: 405,
                    left: 0,
                    right: 0,
                    child: _buildLoginPanel(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 455,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B6870), Color(0xFF07554F)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -20,
              right: -20,
              bottom: 0,
              child: _buildStation(),
            ),
            Positioned(
              top: 26,
              left: 20,
              right: 20,
              child: _buildBrand(),
            ),
          ],
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
              fontSize: 43,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.5,
            ),
            children: [
              TextSpan(text: 'POWER ', style: TextStyle(color: Colors.white)),
              TextSpan(text: '9', style: TextStyle(color: _lime)),
            ],
          ),
        ),
        const Text(
          'Reward App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            height: .95,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Fuel Rewards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          'Brighter Journeys',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildStation() {
    return SizedBox(
      height: 270,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Transform.rotate(
              angle: .055,
              child: Container(
                height: 98,
                decoration: BoxDecoration(
                  color: const Color(0xFF006A50),
                  border: Border(
                    bottom: BorderSide(color: _lime, width: 5),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'POWER 9',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          ...[55.0, 150.0, 245.0, 340.0].map(
            (x) => Positioned(
              left: x,
              bottom: 0,
              child: Container(
                width: 28,
                height: 118,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECE7),
                  border: Border(
                    top: BorderSide(color: _lime, width: 7),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (_) => Container(
                  width: 48,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF087055),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFB4E84C), width: 2),
                  ),
                  child: const Icon(
                    Icons.local_gas_station_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 20,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                color: _darkGreen,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login to your account and continue\nyour POWER 9 rewards journey.',
              style: TextStyle(
                color: Color(0xFF748294),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('login_identifier'),
              controller: _userController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Email address or phone number',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter your email or phone number.'
                      : null,
            ),
            const SizedBox(height: 14),
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
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _darkGreen,
                  ),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Please enter your password.'
                      : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('forgot_password'),
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: _green,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 54,
              child: FilledButton(
                key: const Key('login_button'),
                onPressed: _login,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFFD4DDE0))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Color(0xFF788695),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFFD4DDE0))),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                key: const Key('create_account_button'),
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildRegisterFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Color(0xFF748092), fontSize: 13),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Register now.',
            style: TextStyle(
              color: _green,
              fontSize: 13,
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
      hintStyle: const TextStyle(color: Color(0xFF8997A7), fontSize: 14),
      prefixIcon: Icon(icon, color: _darkGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFCFDFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFD4DDE0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFD4DDE0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _green, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
