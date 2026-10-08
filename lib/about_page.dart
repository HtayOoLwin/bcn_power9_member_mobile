import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  static const green = Color(0xFF006B50);
  static const darkGreen = Color(0xFF004E45);
  static const mint = Color(0xFFE7F5EF);
  static const background = Color(0xFFF6F8F5);

  static final Uri websiteUri = Uri.parse('https://www.bcncl.com');
  static final Uri supportUri = Uri.parse('https://support.bcncl.com/');

  String appVersion = '-';
  String buildNumber = '-';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;

    setState(() {
      appVersion = info.version.trim();
      buildNumber = info.buildNumber.trim();
    });
  }

  Future<void> _openUrl(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
          children: [
            _section(
              icon: Icons.info_rounded,
              title: 'App Information',
              children: [
                _InfoRow(
                  label: 'App Version',
                  value: appVersion,
                ),
                _InfoRow(
                  label: 'Build Number',
                  value: buildNumber,
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.business_rounded,
              title: 'Company Information',
              children: [
                const _InfoRow(
                  label: 'Created By',
                  value: 'Business Centric Network Co., Ltd.',
                ),
                const _InfoRow(
                  label: 'Developed For',
                  value: 'POWER 9',
                ),
                _LinkRow(
                  label: 'Website',
                  value: 'https://www.bcncl.com',
                  onTap: () => _openUrl(context, websiteUri),
                ),
                _LinkRow(
                  label: 'Support Email',
                  value: 'https://support.bcncl.com/',
                  showDivider: false,
                  onTap: () => _openUrl(context, supportUri),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Text(
              '© 2026 Business Centric Network Co., Ltd.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF66736E),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF66736E),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE5E1)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: green, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE5EAE7)),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4D5854),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF111817),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFE5EAE7)),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 118,
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4D5854),
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: _AboutPageState.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.open_in_new_rounded,
              size: 20,
              color: _AboutPageState.green,
            ),
          ],
        ),
      ),
    );
  }
}
