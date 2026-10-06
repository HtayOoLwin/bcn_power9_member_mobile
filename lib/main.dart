import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'member_registration_page.dart';
import 'auth_service.dart';
import 'member_home_page.dart';
import 'forgot_password_page.dart';

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
  bool _rememberMe = false;
  bool _isLoggingIn = false;
  bool _isRestoringSession = true;
  String? _loginError;
  final MemberAuthService _authService = MemberAuthService();

  static const _rememberMeKey = 'power9_member_remember_me';
  static const _rememberedIdentifierKey =
      'power9_member_remembered_identifier';

  static const green = Color(0xFF008B68);
  static const darkGreen = Color(0xFF004E45);
  static const lime = Color(0xFF9EE322);

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
    _restoreSession();
  }

  Future<void> _loadRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    final identifier = prefs.getString(_rememberedIdentifierKey) ?? '';

    if (!mounted) return;

    setState(() {
      _rememberMe = rememberMe;
      if (rememberMe && identifier.isNotEmpty) {
        _userController.text = identifier;
      }
    });
  }

  Future<void> _saveRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(
        _rememberedIdentifierKey,
        _userController.text.trim(),
      );
    } else {
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_rememberedIdentifierKey);
    }
  }

  Future<void> _restoreSession() async {
    final result = await _authService.restoreSession();
    if (!mounted) return;

    if (result == null) {
      setState(() => _isRestoringSession = false);
      return;
    }

    await _continueAfterAuthentication(result.fullName);

    if (mounted) {
      setState(() => _isRestoringSession = false);
    }
  }

  Future<void> _continueAfterAuthentication(String fullName) async {
    final decision = await _MemberAppVersionService().check(_authService);
    if (!mounted) return;

    if (decision.isRequired) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _UpdateRequiredPage(decision: decision),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MemberHomePage(
          fullName: fullName,
          authService: _authService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    final result = await _authService.login(
      user: _userController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoggingIn = false);

    if (!result.success) {
      setState(() => _loginError = result.message ?? 'Login failed.');
      return;
    }

    await _saveRememberedLogin();
    await _authService.persistSession(rememberMe: _rememberMe);
    if (!mounted) return;

    await _continueAfterAuthentication(result.fullName);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: green),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
            final heroHeight = h * .48;
            final panelTop = h * .43;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SizedBox(
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
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      top: keyboardOpen ? h * .25 : panelTop,
                      left: 0,
                      right: 0,
                      bottom: keyboardOpen ? null : 0,
                      child: _loginPanel(h, keyboardOpen: keyboardOpen),
                    ),
                  ],
                ),
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

  Widget _loginPanel(double screenHeight, {bool keyboardOpen = false}) {
    final compact = screenHeight < 760 || keyboardOpen;
    final pad = compact ? 18.0 : 22.0;
    return Container(
      padding: EdgeInsets.fromLTRB(24, keyboardOpen ? 14 : pad, 24, keyboardOpen ? 14 : 10),
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
                fontSize: keyboardOpen ? 21 : (compact ? 24 : 27),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: keyboardOpen ? 2 : (compact ? 3 : 5)),
            Text(
              'Login to your account and continue\nyour POWER 9 rewards journey.',
              style: TextStyle(
                color: const Color(0xFF748294),
                fontSize: keyboardOpen ? 11 : (compact ? 12 : 13),
                height: 1.25,
              ),
            ),
            SizedBox(height: keyboardOpen ? 7 : (compact ? 10 : 14)),
            SizedBox(
              height: keyboardOpen ? 43 : (compact ? 48 : 52),
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
            SizedBox(height: keyboardOpen ? 6 : (compact ? 8 : 10)),
            SizedBox(
              height: keyboardOpen ? 43 : (compact ? 48 : 52),
              child: TextFormField(
                key: const Key('login_password'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) { _login(); },
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
              height: keyboardOpen ? 31 : (compact ? 36 : 40),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      key: const Key('remember_me_checkbox'),
                      value: _rememberMe,
                      activeColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Remember me',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    key: const Key('forgot_password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ForgotPasswordPage(
                            authService: _authService,
                            initialEmail: _userController.text.trim(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: green,
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: keyboardOpen ? 40 : (compact ? 44 : 48),
              child: FilledButton(
                key: const Key('login_button'),
                onPressed: _isLoggingIn ? null : () { _login(); },
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: _isLoggingIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: compact ? 15 : 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            if (_loginError != null) ...[
              const SizedBox(height: 6),
              Text(
                _loginError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: keyboardOpen ? 5 : (compact ? 8 : 11)),
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
            SizedBox(height: keyboardOpen ? 5 : (compact ? 8 : 11)),
            SizedBox(
              height: keyboardOpen ? 39 : (compact ? 43 : 47),
              child: OutlinedButton.icon(
                key: const Key('create_account_button'),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MemberRegistrationPage(),
                    ),
                  ),
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
            if (!keyboardOpen) const Spacer(),
            if (!keyboardOpen) Padding(
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
                      onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MemberRegistrationPage(),
                    ),
                  ),
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


enum _AppUpdateStatus { current, optional, required, unavailable }

class _AppUpdateInfo {
  const _AppUpdateInfo({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.forceUpdate,
    required this.updateMessage,
    required this.androidUrl,
    required this.iosUrl,
  });

  factory _AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return _AppUpdateInfo(
      latestVersion: (json['latest_version'] ?? '').toString().trim(),
      minSupportedVersion:
          (json['min_supported_version'] ?? '').toString().trim(),
      forceUpdate: _boolValue(json['force_update']),
      updateMessage: (json['update_message'] ?? '').toString().trim(),
      androidUrl: (json['android_url'] ?? '').toString().trim(),
      iosUrl: (json['ios_url'] ?? '').toString().trim(),
    );
  }

  final String latestVersion;
  final String minSupportedVersion;
  final bool forceUpdate;
  final String updateMessage;
  final String androidUrl;
  final String iosUrl;

  String get message => updateMessage.isEmpty
      ? 'A new POWER 9 Member App update is available.'
      : updateMessage;

  String get updateUrl {
    if (Platform.isIOS && iosUrl.isNotEmpty) {
      return iosUrl;
    }
    return androidUrl;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'on';
  }
}

class _AppUpdateDecision {
  const _AppUpdateDecision({
    required this.status,
    required this.currentVersion,
    this.info,
  });

  final _AppUpdateStatus status;
  final String currentVersion;
  final _AppUpdateInfo? info;

  bool get isRequired => status == _AppUpdateStatus.required;

  String get message => info?.message ??
      'A new POWER 9 Member App update is required.';

  String get updateUrl => info?.updateUrl ?? '';
}

class _MemberAppVersionService {
  static const String _settingsDoctype =
      'Member App Version Control Settings';

  Future<_AppUpdateDecision> check(MemberAuthService authService) async {
    String currentVersion = '';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version.trim();

      final info = await _fetchSettings(authService);
      final current = _AppVersion.parse(currentVersion);
      final latest = _AppVersion.parse(info.latestVersion);
      final minimum = _AppVersion.parse(info.minSupportedVersion);

      if (!current.isValid) {
        return _AppUpdateDecision(
          status: _AppUpdateStatus.unavailable,
          currentVersion: currentVersion,
        );
      }

      final belowMinimum =
          minimum.isValid && current.compareTo(minimum) < 0;
      final belowLatest =
          latest.isValid && current.compareTo(latest) < 0;

      if (belowMinimum || (info.forceUpdate && belowLatest)) {
        return _AppUpdateDecision(
          status: _AppUpdateStatus.required,
          currentVersion: currentVersion,
          info: info,
        );
      }

      if (belowLatest) {
        return _AppUpdateDecision(
          status: _AppUpdateStatus.optional,
          currentVersion: currentVersion,
          info: info,
        );
      }

      return _AppUpdateDecision(
        status: _AppUpdateStatus.current,
        currentVersion: currentVersion,
        info: info,
      );
    } catch (_) {
      // Fail open if version settings cannot be reached, so a temporary
      // server/network problem does not permanently lock members out.
      return _AppUpdateDecision(
        status: _AppUpdateStatus.unavailable,
        currentVersion: currentVersion,
      );
    }
  }

  Future<_AppUpdateInfo> _fetchSettings(
    MemberAuthService authService,
  ) async {
    final baseUri = Uri.parse(authService.currentBaseUrl);
    final doctype = Uri.encodeComponent(_settingsDoctype);
    final uri = baseUri.resolve('/api/resource/$doctype/$doctype');
    final client = HttpClient();

    try {
      final request = await client.getUrl(uri);
      request.cookies.addAll(authService.sessionCookies);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Unable to read $_settingsDoctype.',
          uri: uri,
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map || decoded['data'] is! Map) {
        throw const FormatException('Invalid version settings response.');
      }

      return _AppUpdateInfo.fromJson(
        Map<String, dynamic>.from(decoded['data'] as Map),
      );
    } finally {
      client.close(force: true);
    }
  }
}

class _AppVersion implements Comparable<_AppVersion> {
  const _AppVersion(this.parts, this.isValid);

  factory _AppVersion.parse(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      return const _AppVersion(<int>[], false);
    }

    final parsed = <int>[];
    for (final part in value.split('+').first.split('.')) {
      final match = RegExp(r'^\d+').firstMatch(part.trim());
      if (match == null) {
        return const _AppVersion(<int>[], false);
      }
      parsed.add(int.parse(match.group(0)!));
    }

    return _AppVersion(parsed, parsed.isNotEmpty);
  }

  final List<int> parts;
  final bool isValid;

  @override
  int compareTo(_AppVersion other) {
    final length = parts.length > other.parts.length
        ? parts.length
        : other.parts.length;

    for (var i = 0; i < length; i++) {
      final left = i < parts.length ? parts[i] : 0;
      final right = i < other.parts.length ? other.parts[i] : 0;

      if (left != right) {
        return left.compareTo(right);
      }
    }

    return 0;
  }
}

class _UpdateRequiredPage extends StatefulWidget {
  const _UpdateRequiredPage({required this.decision});

  final _AppUpdateDecision decision;

  @override
  State<_UpdateRequiredPage> createState() => _UpdateRequiredPageState();
}

class _UpdateRequiredPageState extends State<_UpdateRequiredPage> {
  static const green = Color(0xFF008B68);
  static const darkGreen = Color(0xFF004E45);

  bool _opening = false;
  String? _error;

  Future<void> _updateNow() async {
    final rawUrl = widget.decision.updateUrl.trim();

    if (rawUrl.isEmpty) {
      setState(() => _error = 'Update download link is not configured.');
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || uri.scheme.toLowerCase() != 'https') {
      setState(() => _error = 'Update download link is invalid.');
      return;
    }

    setState(() {
      _opening = true;
      _error = null;
    });

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        setState(() => _error = 'Unable to open the update link.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to open the update link.');
      }
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.decision.info;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8F6),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6F1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.system_update_alt_rounded,
                          color: green,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Update Required',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.decision.message,
                        style: const TextStyle(
                          color: Color(0xFF6F7E79),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _VersionRow(
                        label: 'Current Version',
                        value: widget.decision.currentVersion,
                      ),
                      const Divider(height: 22),
                      _VersionRow(
                        label: 'Latest Version',
                        value: info?.latestVersion ?? '-',
                      ),
                      const Divider(height: 22),
                      _VersionRow(
                        label: 'Minimum Supported',
                        value: info?.minSupportedVersion ?? '-',
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _opening ? null : _updateNow,
                          style: FilledButton.styleFrom(
                            backgroundColor: green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _opening
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.open_in_new_rounded),
                          label: Text(
                            _opening ? 'Opening...' : 'Update Now',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71807B),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            color: Color(0xFF004E45),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
