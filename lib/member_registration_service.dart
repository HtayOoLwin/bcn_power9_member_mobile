import 'dart:convert';
import 'dart:io';

import 'auth_service.dart';

class MemberRegistrationResult {
  const MemberRegistrationResult.success({
    required this.memberId,
    required this.message,
  }) : success = true;

  const MemberRegistrationResult.failure(this.message)
      : success = false,
        memberId = '';

  final bool success;
  final String message;
  final String memberId;
}

class MemberTypeOptionsResult {
  const MemberTypeOptionsResult.success(
    this.memberTypes, {
    required this.defaultMemberType,
  })  : success = true,
        message = null;

  const MemberTypeOptionsResult.failure(this.message)
      : success = false,
        memberTypes = const [],
        defaultMemberType = '';

  final bool success;
  final String? message;
  final List<String> memberTypes;
  final String defaultMemberType;
}

class MemberRegistrationService {
  final HttpClient _client = HttpClient();

  Future<MemberTypeOptionsResult> getMemberTypes() async {
    try {
      final request = await _client.getUrl(
        Uri.parse(
          '${MemberAuthService.baseUrl}/api/method/power9_member_register?action=options',
        ),
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final payload = _decode(body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MemberTypeOptionsResult.failure(
          _error(payload) ?? 'Unable to load member types.',
        );
      }

      final message = payload['message'];
      if (message is! Map) {
        return const MemberTypeOptionsResult.failure(
          'Invalid member type response.',
        );
      }

      final data = Map<String, dynamic>.from(message);
      final rawTypes = data['member_types'];
      final memberTypes = <String>[];

      if (rawTypes is List) {
        for (final raw in rawTypes) {
          if (raw is Map) {
            final row = Map<String, dynamic>.from(raw);
            final value =
                (row['name'] ?? row['member_type_name'] ?? '').toString().trim();
            if (value.isNotEmpty && !memberTypes.contains(value)) {
              memberTypes.add(value);
            }
          } else {
            final value = raw.toString().trim();
            if (value.isNotEmpty && !memberTypes.contains(value)) {
              memberTypes.add(value);
            }
          }
        }
      }

      final configuredDefault =
          (data['default_member_type'] ?? '').toString().trim();
      final defaultMemberType = configuredDefault.isNotEmpty
          ? configuredDefault
          : (memberTypes.length == 1 ? memberTypes.first : '');

      return MemberTypeOptionsResult.success(
        memberTypes,
        defaultMemberType: defaultMemberType,
      );
    } on SocketException {
      return const MemberTypeOptionsResult.failure(
        'Unable to connect to Power 9 server.',
      );
    } catch (_) {
      return const MemberTypeOptionsResult.failure(
        'Unable to load member types right now.',
      );
    }
  }

  Future<MemberRegistrationResult> register({
    required String memberName,
    required String phone,
    required String email,
    required String gender,
    required String nationality,
    required String address,
    required String dateOfBirth,
    required String idType,
    required String idNumber,
    required String memberType,
  }) async {
    try {
      final request = await _client.postUrl(
        Uri.parse(
          '${MemberAuthService.baseUrl}/api/method/power9_member_register',
        ),
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
            'member_name': memberName.trim(),
            'phone': phone.trim(),
            'email': email.trim(),
            'gender': gender.trim(),
            'nationality': nationality.trim(),
            'address': address.trim(),
            'date_of_birth': dateOfBirth.trim(),
            'id_type': idType.trim(),
            'id_number': idNumber.trim(),
            'member_type': memberType.trim(),
          },
        ).query,
      );

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final payload = _decode(body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message = payload['message'];
        if (message is Map) {
          final data = Map<String, dynamic>.from(message);
          final member = data['member'];
          final memberData = member is Map
              ? Map<String, dynamic>.from(member)
              : <String, dynamic>{};

          return MemberRegistrationResult.success(
            memberId:
                (memberData['member_id'] ?? memberData['name'] ?? '').toString(),
            message:
                (data['message'] ?? 'Member registered successfully.').toString(),
          );
        }

        return const MemberRegistrationResult.success(
          memberId: '',
          message: 'Member registered successfully.',
        );
      }

      return MemberRegistrationResult.failure(
        _error(payload) ?? 'Unable to register member.',
      );
    } on SocketException {
      return const MemberRegistrationResult.failure(
        'Unable to connect to Power 9 server. Check your internet connection.',
      );
    } on HandshakeException {
      return const MemberRegistrationResult.failure(
        'Secure connection to Power 9 server failed.',
      );
    } catch (_) {
      return const MemberRegistrationResult.failure(
        'Unable to register member. Please try again.',
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

    final exception = payload['exception']?.toString() ?? '';
    if (exception.isNotEmpty) {
      final parts = exception.split(':');
      return parts.length > 1 ? parts.last.trim() : exception;
    }

    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    return null;
  }
}
