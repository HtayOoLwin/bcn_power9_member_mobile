import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'auth_service.dart';
import 'member_card_service.dart';

class MembershipCardPage extends StatefulWidget {
  const MembershipCardPage({super.key, required this.authService});
  final MemberAuthService authService;

  @override
  State<MembershipCardPage> createState() => _MembershipCardPageState();
}

class _MembershipCardPageState extends State<MembershipCardPage> {
  static const green = Color(0xFF006B50);
  static const darkGreen = Color(0xFF004E45);
  bool _loading = true;
  String? _error;
  MemberCardData? _card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await MemberCardService(widget.authService).load();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _card = result.data;
      _error = result.success ? null : result.message;
    });
  }

  String _date(String value) {
    if (value.isEmpty) return '-';
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _points(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF008866), darkGreen]),
              ),
              child: const Text(
                'My Membership Card',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: green))
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF82908A)),
                                const SizedBox(height: 12),
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                OutlinedButton(onPressed: _load, child: const Text('Retry')),
                              ],
                            ),
                          ),
                        )
                      : _card == null || !_card!.hasCard
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.credit_card_off_rounded, size: 54, color: Color(0xFF82908A)),
                                  SizedBox(height: 12),
                                  Text('No membership card found.', style: TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                              child: SizedBox.expand(child: _membershipCard(_card!)),
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _membershipCard(MemberCardData data) {
    final status = data.cardStatus.isNotEmpty ? data.cardStatus : data.memberStatus;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF078D6B), Color(0xFF004D42)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('POWER 9', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                          Text('REWARD MEMBER', style: TextStyle(color: Color(0xFFD8F2E8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        data.memberType.isEmpty ? 'MEMBER' : data.memberType.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  data.memberName,
                  style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  data.memberId,
                  style: const TextStyle(color: Color(0xFFD6ECE5), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _greenInfo('CURRENT POINTS', _points(data.currentPoints))),
                    Expanded(child: _greenInfo('CARD NUMBER', data.cardNumber)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                if (data.qrData.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE0E8E4)),
                    ),
                    child: QrImageView(
                      data: data.qrData,
                      version: QrVersions.auto,
                      size: 145,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  )
                else
                  const SizedBox(
                    height: 145,
                    child: Center(child: Text('QR data is not available.')),
                  ),
                const SizedBox(height: 5),
                const Text('Scan Membership Card', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(child: _detail('MEMBER SINCE', _date(data.registrationDate))),
                    Container(width: 1, height: 34, color: const Color(0xFFE3E9E6)),
                    Expanded(child: _detail('EXPIRY DATE', _date(data.expiryDate))),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(radius: 4, backgroundColor: Color(0xFF079447)),
                      const SizedBox(width: 7),
                      Text(
                        status.isEmpty ? 'Active Member' : '$status Member',
                        style: const TextStyle(color: Color(0xFF067647), fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _greenInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFBFE3D8), fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value.isEmpty ? '-' : value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A9691), fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF18332A), fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
