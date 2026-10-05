import 'dart:convert';
import 'dart:io';

import 'auth_service.dart';

class MemberProfile {
  const MemberProfile({
    required this.name,
    required this.memberName,
    required this.memberType,
    required this.status,
    required this.currentPointBalance,
    required this.email,
    required this.phone,
  });

  final String name;
  final String memberName;
  final String memberType;
  final String status;
  final num currentPointBalance;
  final String email;
  final String phone;

  factory MemberProfile.fromJson(Map<String, dynamic> json) => MemberProfile(
        name: (json['name'] ?? '').toString(),
        memberName: (json['member_name'] ?? '').toString(),
        memberType: (json['member_type'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        currentPointBalance: _num(json['current_point_balance']),
        email: (json['email'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
      );
}

class MemberTransaction {
  const MemberTransaction({
    required this.name,
    required this.direction,
    required this.points,
    required this.postingDate,
    required this.postingTime,
    required this.activity,
  });

  final String name;
  final String direction;
  final num points;
  final String postingDate;
  final String postingTime;
  final String activity;

  bool get earned => direction == 'Earn';

  factory MemberTransaction.fromJson(Map<String, dynamic> json) =>
      MemberTransaction(
        name: (json['name'] ?? '').toString(),
        direction: (json['direction'] ?? '').toString(),
        points: _num(json['points']),
        postingDate: (json['posting_date'] ?? '').toString(),
        postingTime: (json['posting_time'] ?? '').toString(),
        activity: (json['point_activity'] ?? json['direction'] ?? '').toString(),
      );
}

class MemberDashboardData {
  const MemberDashboardData({
    required this.profile,
    required this.transactions,
  });

  final MemberProfile profile;
  final List<MemberTransaction> transactions;
}

class MemberDashboardResult {
  const MemberDashboardResult.success(this.data)
      : success = true,
        message = null;
  const MemberDashboardResult.failure(this.message)
      : success = false,
        data = null;

  final bool success;
  final String? message;
  final MemberDashboardData? data;
}

class MemberDashboardService {
  MemberDashboardService(this.authService);

  final MemberAuthService authService;

  static const _dashboardPath =
      '/api/method/power9_member_dashboard';

  Future<MemberDashboardResult> load() async {
    if (authService.sessionCookies.isEmpty) {
      return const MemberDashboardResult.failure(
        'Your login session is not available. Please login again.',
      );
    }

    try {
      final dashboardPayload = await _get(_dashboardPath);
      final dashboardRaw = dashboardPayload['message'];

      if (dashboardRaw is! Map) {
        return const MemberDashboardResult.failure(
          'Member dashboard data was not returned by the server.',
        );
      }

      final dashboard = Map<String, dynamic>.from(dashboardRaw);
      final profileRaw = dashboard['profile'];

      if (profileRaw is! Map) {
        return const MemberDashboardResult.failure(
          'Member profile was not returned by the server.',
        );
      }

      final transactions = <MemberTransaction>[];
      final txRows = dashboard['transactions'];

      if (txRows is List) {
        for (final raw in txRows.whereType<Map>()) {
          transactions.add(
            MemberTransaction.fromJson(Map<String, dynamic>.from(raw)),
          );
        }
      }

      return MemberDashboardResult.success(
        MemberDashboardData(
          profile: MemberProfile.fromJson(
            Map<String, dynamic>.from(profileRaw),
          ),
          transactions: transactions,
        ),
      );
    } on HttpException catch (e) {
      return MemberDashboardResult.failure(e.message);
    } on SocketException {
      return const MemberDashboardResult.failure(
        'Unable to connect to Power 9 server.',
      );
    } catch (_) {
      return const MemberDashboardResult.failure(
        'Unable to load your member information right now.',
      );
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(authService.currentBaseUrl)
        .resolve(path)
        .replace(queryParameters: query);
    final client = HttpClient();
    final request = await client.getUrl(uri);
    request.cookies.addAll(authService.sessionCookies);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    final payload = _decode(body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(_error(payload));
    }
    return payload;
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return const {};
    final decoded = jsonDecode(body);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : const <String, dynamic>{};
  }

  String _error(Map<String, dynamic> payload) {
    final messages = payload['_server_messages'];
    if (messages is String && messages.isNotEmpty) {
      try {
        final decoded = jsonDecode(messages);
        if (decoded is List && decoded.isNotEmpty) {
          final inner = jsonDecode(decoded.first.toString());
          if (inner is Map && inner['message'] != null) {
            return inner['message'].toString();
          }
        }
      } catch (_) {}
    }
    return (payload['exception'] ?? payload['message'] ?? 'Request failed.')
        .toString();
  }
}

num _num(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}
