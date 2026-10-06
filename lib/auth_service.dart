import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginResult {
  const LoginResult.success({required this.fullName})
      : success = true,
        message = null;
  const LoginResult.failure(this.message)
      : success = false,
        fullName = '';

  final bool success;
  final String? message;
  final String fullName;
}

class MemberAuthService {
  static const baseUrl = 'https://power9-member.s.frappe.cloud';
  static const bcnclBaseUrl = 'https://power9-dev.s.frappe.cloud';

  final HttpClient _client = HttpClient();
  Uri _baseUri = Uri.parse(baseUrl);
  static const _secureStorage = FlutterSecureStorage();
  static const _sessionCookieKey = 'power9_member_session_cookies';
  static const _sessionFullNameKey = 'power9_member_session_full_name';
  static const _sessionBaseUrlKey = 'power9_member_session_base_url';
  List<Cookie> _sessionCookies = const [];
  String _sessionFullName = '';

  List<Cookie> get sessionCookies => List.unmodifiable(_sessionCookies);
  String get currentBaseUrl => _baseUri.toString();
  String get connectedServer => _baseUri.host;

  Future<LoginResult> login({
    required String user,
    required String password,
  }) async {
    try {
      var loginUser = user.trim();
      _baseUri = _baseUriForIdentifier(loginUser);

      final isPhone = RegExp(r'^09[0-9]+$').hasMatch(loginUser);
      if (isPhone) {
        final resolveUri = _baseUri
            .resolve('/api/method/power9_resolve_login_identifier')
            .replace(
          queryParameters: {
            'identifier': loginUser,
          },
        );

        final resolveRequest = await _client.getUrl(resolveUri);
        resolveRequest.headers.set(
          HttpHeaders.acceptHeader,
          'application/json',
        );

        final resolveResponse = await resolveRequest.close();
        final resolveBody =
            await utf8.decoder.bind(resolveResponse).join();
        final resolvePayload = _decode(resolveBody);

        if (resolveResponse.statusCode < 200 ||
            resolveResponse.statusCode >= 300) {
          return LoginResult.failure(
            _error(resolvePayload) ?? 'Invalid phone number.',
          );
        }

        final resolveMessage = resolvePayload['message'];
        if (resolveMessage is! Map || resolveMessage['user'] == null) {
          return const LoginResult.failure(
            'Unable to find a user for this phone number.',
          );
        }

        loginUser = resolveMessage['user'].toString().trim();
        if (loginUser.isEmpty) {
          return const LoginResult.failure(
            'Unable to find a user for this phone number.',
          );
        }
      }

      final uri = _baseUri.resolve('/api/method/login');
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.write(
        Uri(
          queryParameters: {
            'usr': loginUser,
            'pwd': password,
          },
        ).query,
      );

      final response = await request.close();
      final responseBody = await utf8.decoder.bind(response).join();
      final payload = _decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _sessionCookies = response.cookies;
        _sessionFullName = (payload['full_name'] ?? loginUser).toString();
        return LoginResult.success(
          fullName: _sessionFullName,
        );
      }

      return LoginResult.failure(
        _error(payload) ??
            'Invalid email, username, phone number, or password.',
      );
    } on SocketException {
      return const LoginResult.failure(
        'Unable to connect to Power 9 server. Check your internet connection.',
      );
    } on HandshakeException {
      return const LoginResult.failure(
        'Secure connection to Power 9 server failed.',
      );
    } on FormatException {
      return const LoginResult.failure(
        'Power 9 server returned an invalid response.',
      );
    } catch (_) {
      return const LoginResult.failure(
        'Unable to sign in right now. Please try again.',
      );
    }
  }

  Future<void> persistSession({required bool rememberMe}) async {
    if (!rememberMe || _sessionCookies.isEmpty) {
      await clearSavedSession();
      return;
    }

    final cookieValue = _sessionCookies
        .map((cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    await _secureStorage.write(
      key: _sessionCookieKey,
      value: cookieValue,
    );
    await _secureStorage.write(
      key: _sessionFullNameKey,
      value: _sessionFullName,
    );
    await _secureStorage.write(
      key: _sessionBaseUrlKey,
      value: _baseUri.toString(),
    );
  }

  Future<LoginResult?> restoreSession() async {
    final storedCookies = await _secureStorage.read(key: _sessionCookieKey);
    if (storedCookies == null || storedCookies.trim().isEmpty) return null;

    final storedBaseUrl = await _secureStorage.read(key: _sessionBaseUrlKey);
    _baseUri = Uri.parse(
      storedBaseUrl == null || storedBaseUrl.trim().isEmpty
          ? baseUrl
          : storedBaseUrl,
    );

    final cookies = <Cookie>[];
    for (final part in storedCookies.split(';')) {
      final value = part.trim();
      final separator = value.indexOf('=');
      if (separator <= 0) continue;
      cookies.add(
        Cookie(
          value.substring(0, separator),
          value.substring(separator + 1),
        ),
      );
    }

    if (cookies.isEmpty) return null;

    try {
      final uri = _baseUri.resolve('/api/method/frappe.auth.get_logged_user');
      final request = await _client.getUrl(uri);
      request.cookies.addAll(cookies);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final payload = _decode(body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await clearSavedSession();
        return null;
      }

      final user = payload['message']?.toString().trim() ?? '';
      if (user.isEmpty || user == 'Guest') {
        await clearSavedSession();
        return null;
      }

      _sessionCookies = cookies;
      _sessionFullName =
          (await _secureStorage.read(key: _sessionFullNameKey))?.trim() ?? '';

      return LoginResult.success(
        fullName: _sessionFullName.isEmpty ? user : _sessionFullName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavedSession() async {
    await _secureStorage.delete(key: _sessionCookieKey);
    await _secureStorage.delete(key: _sessionFullNameKey);
    await _secureStorage.delete(key: _sessionBaseUrlKey);
  }

  Future<void> logout() async {
    try {
      final request = await _client.getUrl(
        _baseUri.resolve('/api/method/logout'),
      );
      request.cookies.addAll(_sessionCookies);
      await request.close();
    } catch (_) {
      // Always clear local session even if server logout fails.
    } finally {
      _sessionCookies = const [];
      _sessionFullName = '';
      await clearSavedSession();
      _baseUri = Uri.parse(baseUrl);
    }
  }

  Uri _baseUriForIdentifier(String identifier) {
    final value = identifier.trim().toLowerCase();
    if (value.contains('@') && value.endsWith('@bcncl.com')) {
      return Uri.parse(bcnclBaseUrl);
    }
    return Uri.parse(baseUrl);
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return const {};
    try {
      final value = jsonDecode(body);
      return value is Map ? Map<String, dynamic>.from(value) : const {};
    } catch (_) {
      return const {};
    }
  }

  String? _error(Map<String, dynamic> payload) {
    final serverMessages = payload['_server_messages'];
    if (serverMessages is String && serverMessages.isNotEmpty) {
      try {
        final messages = jsonDecode(serverMessages);
        if (messages is List && messages.isNotEmpty) {
          final first = messages.first;
          if (first is String) {
            final item = jsonDecode(first);
            if (item is Map && item['message'] != null) {
              return item['message'].toString();
            }
          }
        }
      } catch (_) {}
    }

    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    final exception = payload['exception']?.toString() ?? '';
    if (exception.toLowerCase().contains('authentication')) {
      return 'Invalid email or password.';
    }
    return exception.isEmpty ? null : exception;
  }
}
