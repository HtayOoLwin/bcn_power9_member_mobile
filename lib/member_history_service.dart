import 'dart:convert';
import 'dart:io';

import 'auth_service.dart';
import 'member_dashboard_service.dart';

class MemberHistoryResult {
  const MemberHistoryResult.success(this.transactions, this.count)
      : success = true,
        message = null;
  const MemberHistoryResult.failure(this.message)
      : success = false,
        transactions = const [],
        count = 0;

  final bool success;
  final String? message;
  final List<MemberTransaction> transactions;
  final int count;
}

class MemberHistoryService {
  MemberHistoryService(this.authService);

  final MemberAuthService authService;

  static const _path = '/api/method/power9_member_activity_history';

  Future<MemberHistoryResult> load({
    DateTime? fromDate,
    DateTime? toDate,
    String? direction,
    int limit = 5000,
  }) async {
    if (authService.sessionCookies.isEmpty) {
      return const MemberHistoryResult.failure(
        'Your login session is not available. Please login again.',
      );
    }

    try {
      final query = <String, String>{'limit': limit.toString()};
      if (fromDate != null) query['from_date'] = _apiDate(fromDate);
      if (toDate != null) query['to_date'] = _apiDate(toDate);
      if (direction != null && direction.isNotEmpty) {
        query['direction'] = direction;
      }

      final uri = Uri.parse(MemberAuthService.baseUrl)
          .resolve(_path)
          .replace(queryParameters: query);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.cookies.addAll(authService.sessionCookies);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        return const MemberHistoryResult.failure('Invalid server response.');
      }
      final payload = Map<String, dynamic>.from(decoded);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MemberHistoryResult.failure(_error(payload));
      }

      final message = payload['message'];
      if (message is! Map) {
        return const MemberHistoryResult.failure('Invalid history response.');
      }

      final rows = message['activities'];
      final transactions = <MemberTransaction>[];
      if (rows is List) {
        for (final raw in rows.whereType<Map>()) {
          transactions.add(
            MemberTransaction.fromJson(Map<String, dynamic>.from(raw)),
          );
        }
      }

      return MemberHistoryResult.success(
        transactions,
        int.tryParse((message['count'] ?? transactions.length).toString()) ??
            transactions.length,
      );
    } on SocketException {
      return const MemberHistoryResult.failure(
        'Unable to connect to Power 9 server.',
      );
    } catch (_) {
      return const MemberHistoryResult.failure(
        'Unable to load point history right now.',
      );
    }
  }

  static String _apiDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _error(Map<String, dynamic> payload) {
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
