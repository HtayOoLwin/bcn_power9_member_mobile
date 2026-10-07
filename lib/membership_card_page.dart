import 'dart:async';

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

class _MembershipCardPageState extends State<MembershipCardPage> with WidgetsBindingObserver {
  static const green = Color(0xFF006B50);
  static const darkGreen = Color(0xFF004E45);
  bool _loading = true;
  String? _error;
  MemberCardData? _card;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _load(silent: true),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _autoRefreshTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await MemberCardService(widget.authService).load();
    if (!mounted) return;
    setState(() {
      if (!silent) _loading = false;
      if (result.success) {
        _card = result.data;
        _error = null;
      } else if (!silent) {
        _error = result.message;
      }
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
                'Membership Card',
                textAlign: TextAlign.center,
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
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              child: Column(
                                children: [
                                  Expanded(child: _membershipCard(_card!)),
                                  const SizedBox(height: 8),
                                  _securityNote(),
                                ],
                              ),
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
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003F2D), Color(0xFF087A49), Color(0xFF005338)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: 'POWER ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                            TextSpan(text: '9', style: TextStyle(color: Color(0xFF9DE65E), fontSize: 34, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF2D36D), size: 34),
                        Text(
                          data.memberType.isEmpty ? 'MEMBER' : data.memberType.toUpperCase(),
                          style: const TextStyle(color: Color(0xFFF2D36D), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
                const Text(
                  'R E W A R D   M E M B E R',
                  style: TextStyle(color: Color(0xFFF0CF79), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
                const SizedBox(height: 18),
                Text(
                  data.memberName,
                  style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFEAA0), Color(0xFFE8BE55)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '${data.memberType.isEmpty ? 'Member' : data.memberType} Member',
                    style: const TextStyle(color: Color(0xFF164A37), fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 12),
                _cardInfoRow('Member ID', data.memberId),
                _cardInfoRow('Current Points', _points(data.currentPoints)),
                _cardInfoRow('Member Since', _date(data.registrationDate)),
                _cardInfoRow('Expiry Date', _date(data.expiryDate)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Column(
              children: [
                if (data.qrData.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: QrImageView(
                      data: data.qrData,
                      version: QrVersions.auto,
                      size: 155,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  )
                else
                  const SizedBox(
                    height: 155,
                    child: Center(child: Text('QR data is not available.')),
                  ),
                const SizedBox(height: 7),
                const Text('Scan to identify member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xAA003D2C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 4, backgroundColor: Color(0xFF8EEB59)),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          status.isEmpty ? 'Active Member' : '$status Member',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(width: 1, height: 20, color: const Color(0x668EEBBA)),
                      const SizedBox(width: 12),
                      const Icon(Icons.monetization_on_rounded, color: Color(0xFF9DE65E), size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${_points(data.currentPoints)} Points',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
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

  Widget _cardInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: const TextStyle(color: Color(0xFFC3D7D0), fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }


  Widget _securityNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E9DF)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE6F7ED),
            child: Icon(Icons.verified_user_rounded, color: Color(0xFF087A49), size: 21),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This QR Code is encrypted for secure verification.\nPlease present this code when making a purchase or earning points.',
              style: TextStyle(color: Color(0xFF29433A), fontSize: 10.5, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

}
