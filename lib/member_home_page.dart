import 'package:flutter/material.dart';

class MemberHomePage extends StatelessWidget {
  const MemberHomePage({super.key, required this.fullName});
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF006B50),
        foregroundColor: Colors.white,
        title: const Text('POWER 9 Reward App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 72, color: Color(0xFF008B68)),
              const SizedBox(height: 16),
              Text(
                'Welcome, $fullName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF004E45),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login successful.',
                style: TextStyle(color: Color(0xFF748294)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
