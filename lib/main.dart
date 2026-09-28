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
  static const navy = Color(0xFF07152B);

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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * .43;
          return SingleChildScrollView(
            child: Column(
              children: [
                _hero(heroHeight),
                Transform.translate(
                  offset: const Offset(0, -38),
                  child: _loginCard(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero(double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/power9_station.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, .32),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55002735),
                  Color(0x16002735),
                  Color(0x33001318),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Align(
                alignment: Alignment.topCenter,
                child: _brand(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.4,
              shadows: [Shadow(color: Color(0x55000000), blurRadius: 6)],
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
            fontSize: 27,
            height: .95,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Color(0x55000000), blurRadius: 5)],
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Fuel Rewards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Color(0x55000000), blurRadius: 4)],
          ),
        ),
        const Text(
          'Brighter Journeys',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            shadows: [Shadow(color: Color(0x55000000), blurRadius: 4)],
          ),
        ),
      ],
    );
  }

  Widget _loginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 22,
            offset: Offset(0, -4),
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
                color: darkGreen,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Login to your account and continue\nyour POWER 9 rewards journey.',
              style: TextStyle(
                color: Color(0xFF748294),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('login_identifier'),
              controller: _userController,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                'Email address or phone number',
                Icons.mail_outline_rounded,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your email or phone number.'
                  : null,
            ),
            const SizedBox(height: 13),
            TextFormField(
              key: const Key('login_password'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: _decoration(
                'Password',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: darkGreen,
                  ),
                ),
              ),
              validator: (v) => v == null || v.isEmpty
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
                    color: green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: FilledButton(
                key: const Key('login_button'),
                onPressed: _login,
                style: FilledButton.styleFrom(
                  backgroundColor: green,
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
            const SizedBox(height: 18),
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
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                key: const Key('create_account_button'),
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 17),
            Row(
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
                      color: green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8997A7), fontSize: 14),
      prefixIcon: Icon(icon, color: darkGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFCFDFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: _border(const Color(0xFFD4DDE0)),
      enabledBorder: _border(const Color(0xFFD4DDE0)),
      focusedBorder: _border(green, width: 1.6),
      errorBorder: _border(Colors.redAccent),
      focusedErrorBorder: _border(Colors.redAccent),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
