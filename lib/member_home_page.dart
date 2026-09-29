import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'member_dashboard_service.dart';

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({
    super.key,
    required this.fullName,
    required this.authService,
  });
  final String fullName;
  final MemberAuthService authService;

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  static const green = Color(0xFF006B50);
  static const darkGreen = Color(0xFF004E45);
  static const mint = Color(0xFFE7F5EF);
  int _index = 0;
  MemberDashboardData? _data;
  String? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final result = await MemberDashboardService(widget.authService).load();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _data = result.data;
      _loadError = result.success ? null : result.message;
    });
  }

  String _points(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      body: SafeArea(
        child: IndexedStack(
        index: _index,
          children: [
            _home(),
            const _ComingSoonPage(
              icon: Icons.qr_code_2_rounded,
              title: 'My Membership Card',
            ),
            _history(),
            _profile(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        indicatorColor: mint,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: green),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_2_rounded),
            selectedIcon: Icon(Icons.qr_code_2_rounded, color: green),
            label: 'My Card',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: green),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: green),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _home() {
    return RefreshIndicator(
      color: green,
      onRefresh: _loadDashboard,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello,',
                    style: TextStyle(color: Color(0xFF718092), fontSize: 14),
                  ),
                  Text(
                    _data?.profile.memberName.isNotEmpty == true
                        ? _data!.profile.memberName
                        : widget.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF102032),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Good to see you again!',
                    style: TextStyle(color: Color(0xFF718092), fontSize: 12),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: mint, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, size: 30, color: darkGreen),
                ),
                const Positioned(
                  right: -3,
                  top: -3,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.notifications_none_rounded, size: 17, color: darkGreen),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => setState(() => _index = 2),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0AA77B), Color(0xFF08745C)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SizedBox(width: 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_data?.profile.memberType.isNotEmpty == true
                            ? '${_data!.profile.memberType} Member'
                            : 'Member'),
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_points(_data?.profile.currentPointBalance ?? 0)} Points',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Activity',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 2),
              child: const Text('View All', style: TextStyle(color: green)),
            ),
          ],
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: green)),
          )
        else if (_loadError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
              ],
            ),
          )
        else if (_data!.transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No recent activity.',
                style: TextStyle(color: Color(0xFF758396)),
              ),
            ),
          )
        else
          ..._data!.transactions.map((tx) {
            final sign = tx.earned ? '+' : '-';
            final title = tx.activity.isEmpty
                ? (tx.earned ? 'Points Earned' : 'Points Redeemed')
                : tx.activity;
            final date = [tx.postingDate, tx.postingTime]
                .where((v) => v.isNotEmpty)
                .join(' ');
            return _transaction(
              tx.earned ? Icons.add_circle : Icons.remove_circle,
              title,
              date,
              '$sign ${_points(tx.points)}',
              tx.earned,
            );
          }),
      ],
      ),
    );
  }

  Widget _transaction(
    IconData icon,
    String title,
    String date,
    String points,
    bool earned,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECE9))),
      ),
      child: Row(
        children: [
          Icon(icon, color: earned ? const Color(0xFF08B84E) : Colors.redAccent, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: Color(0xFF758396), fontSize: 11)),
              ],
            ),
          ),
          Text(
            points,
            style: TextStyle(
              color: earned ? const Color(0xFF08A844) : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    return RefreshIndicator(
      color: green,
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          const Text(
            'Point History',
            style: TextStyle(
              color: Color(0xFF102032),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your recent earn and redeem activity',
            style: TextStyle(color: Color(0xFF718092), fontSize: 13),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0AA77B), Color(0xFF08745C)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Current Points',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _points(_data?.profile.currentPointBalance ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Transactions',
            style: TextStyle(
              color: Color(0xFF102032),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator(color: green)),
            )
          else if (_loadError != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _loadDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_data == null || _data!.transactions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 42,
                    color: Color(0xFF9AA6B2),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No point history yet.',
                    style: TextStyle(color: Color(0xFF718092)),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: _data!.transactions.map((tx) {
                  final earned = tx.earned;
                  final title = tx.activity.isEmpty
                      ? (earned ? 'Points Earned' : 'Points Redeemed')
                      : tx.activity;
                  final date = [tx.postingDate, tx.postingTime]
                      .where((value) => value.isNotEmpty)
                      .join(' ');
                  return _transaction(
                    earned ? Icons.add_circle : Icons.remove_circle,
                    title,
                    date,
                    '${earned ? '+' : '-'} ${_points(tx.points)}',
                    earned,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profile() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 12),
        const CircleAvatar(
          radius: 46,
          backgroundColor: mint,
          child: Icon(Icons.person_rounded, size: 56, color: darkGreen),
        ),
        const SizedBox(height: 14),
        Text(
          widget.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'POWER 9 Member',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF718092)),
        ),
        const SizedBox(height: 26),
        _profileTile(Icons.description_outlined, 'Terms & Conditions'),
        _profileTile(Icons.privacy_tip_outlined, 'Privacy Policy'),
        _profileTile(Icons.info_outline_rounded, 'About'),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          tileColor: Colors.white,
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
          ),
          onTap: _confirmLogout,
        ),
      ],
    );
  }

  Widget _profileTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Colors.white,
        leading: Icon(icon, color: darkGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 38),
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout from your account?',
          textAlign: TextAlign.center,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (logout == true && mounted) {
      await widget.authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: const Color(0xFF006B50)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'UI will be connected in the next step.',
            style: TextStyle(color: Color(0xFF718092)),
          ),
        ],
      ),
    );
  }
}
