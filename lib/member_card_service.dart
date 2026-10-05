import 'dart:convert';
import 'dart:io';

import 'auth_service.dart';

class MemberCardData {
  const MemberCardData({
    required this.hasCard,
    required this.memberName,
    required this.memberId,
    required this.memberType,
    required this.memberStatus,
    required this.currentPoints,
    required this.registrationDate,
    required this.cardNumber,
    required this.cardStatus,
    required this.issueDate,
    required this.expiryDate,
    required this.qrData,
  });

  final bool hasCard;
  final String memberName;
  final String memberId;
  final String memberType;
  final String memberStatus;
  final num currentPoints;
  final String registrationDate;
  final String cardNumber;
  final String cardStatus;
  final String issueDate;
  final String expiryDate;
  final String qrData;

  factory MemberCardData.fromJson(Map<String, dynamic> json) {
    final member = json['member'] is Map
        ? Map<String, dynamic>.from(json['member'] as Map)
        : <String, dynamic>{};
    final card = json['card'] is Map
        ? Map<String, dynamic>.from(json['card'] as Map)
        : <String, dynamic>{};
    return MemberCardData(
      hasCard: json['has_card'] == true,
      memberName: (member['member_name'] ?? '').toString(),
      memberId: (member['member_id'] ?? member['name'] ?? '').toString(),
      memberType: (member['member_type'] ?? '').toString(),
      memberStatus: (member['status'] ?? '').toString(),
      currentPoints: num.tryParse((member['current_point_balance'] ?? 0).toString()) ?? 0,
      registrationDate: (member['registration_date'] ?? '').toString(),
      cardNumber: (card['card_number'] ?? '').toString(),
      cardStatus: (card['card_status'] ?? '').toString(),
      issueDate: (card['issue_date'] ?? '').toString(),
      expiryDate: (card['expiry_date'] ?? '').toString(),
      qrData: (card['qr_data'] ?? '').toString(),
    );
  }
}

class MemberCardResult {
  const MemberCardResult.success(this.data) : success = true, message = null;
  const MemberCardResult.failure(this.message) : success = false, data = null;

  final bool success;
  final String? message;
  final MemberCardData? data;
}

class MemberCardService {
  MemberCardService(this.authService);
  final MemberAuthService authService;

  Future<MemberCardResult> load() async {
    if (authService.sessionCookies.isEmpty) {
      return const MemberCardResult.failure('Please login again.');
    }
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('${authService.currentBaseUrl}/api/method/power9_member_card'),
      );
      request.cookies.addAll(authService.sessionCookies);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        return const MemberCardResult.failure('Invalid server response.');
      }
      final root = Map<String, dynamic>.from(decoded);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MemberCardResult.failure(
          (root['exception'] ?? root['message'] ?? 'Unable to load membership card.').toString(),
        );
      }
      if (root['message'] is! Map) {
        return const MemberCardResult.failure('Invalid membership card response.');
      }
      return MemberCardResult.success(
        MemberCardData.fromJson(Map<String, dynamic>.from(root['message'] as Map)),
      );
    } on SocketException {
      return const MemberCardResult.failure('Unable to connect to Power 9 server.');
    } catch (e) {
      return MemberCardResult.failure('Unable to load membership card: $e');
    }
  }
}
