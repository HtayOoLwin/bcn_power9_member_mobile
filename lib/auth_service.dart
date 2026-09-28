import 'dart:convert';
import 'dart:io';

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

  final HttpClient _client = HttpClient();
  List<Cookie> _sessionCookies = const [];

  List<Cookie> get sessionCookies => List.unmodifiable(_sessionCookies);

  Future<LoginResult> login({
    required String user,
    required String password,
  }) async {
    try {
      final request = await _client.postUrl(
        Uri.parse('$baseUrl/api/method/login'),
      );
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.write(
        Uri(
          queryParameters: {
            'usr': user.trim(),
            'pwd': password,
          },
        ).query,
      );

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final payload = _decode(body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _sessionCookies = response.cookies;
        return LoginResult.success(
          fullName: (payload['full_name'] ?? user.trim()).toString(),
        );
      }

      return LoginResult.failure(
        _error(payload) ?? 'Invalid email or password.',
      );
    } on SocketException {
      return const LoginResult.failure(
        'Unable to connect to Power 9 server. Check your internet connection.',
      );
    } on HandshakeException {
      return const LoginResult.failure(
        'Secure connection to Power 9 server failed.',
      );
    } catch (_) {
      return const LoginResult.failure(
        'Unable to sign in right now. Please try again.',
      );
    }
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
