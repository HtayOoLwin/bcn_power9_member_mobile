import 'package:flutter/material.dart';

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key, required this.fullName});
  final String fullName;

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  static const green = Color(0xFF006B50);
  static const darkGreen = Color(0xFF004E45);
  static const mint = Color(0xFFE7F5EF);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text(
          'POWER 9',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Badge(
              smallSize: 7,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _home(),
          const _ComingSoonPage(
            icon: Icons.qr_code_2_rounded,
            title: 'My Membership Card',
          ),
          const _ComingSoonPage(
            icon: Icons.receipt_long_rounded,
            title: 'Point History',
          ),
          _profile(),
        ],
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(color: mint, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 34, color: darkGreen),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome,', style: TextStyle(color: Color(0xFF718092))),
                  Text(
                    widget.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF102032),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'POWER 9 Member',
                    style: TextStyle(color: Color(0xFF718092), fontSize: 12),
                  ),
                ],
              ),
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
                colors: [Color(0xFF0A8A66), Color(0xFF006B50)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.toll_rounded, color: Colors.white, size: 42),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Points', style: TextStyle(color: Colors.white70)),
                      Text(
                        '1,250',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Silver Member',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 116,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 52),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Fuel Rewards\nBrighter Journeys',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 2),
              child: const Text('View All', style: TextStyle(color: green)),
            ),
          ],
        ),
        _transaction(Icons.add_circle, 'Fuel Purchase', '28/09/2026 10:30', '+ 200', true),
        _transaction(Icons.add_circle, 'Bonus Points', '25/09/2026 14:20', '+ 50', true),
        _transaction(Icons.remove_circle, 'Redeem Reward', '20/09/2026 11:15', '- 300', false),
        _transaction(Icons.add_circle, 'Welcome Bonus', '15/09/2026 09:40', '+ 1,000', true),
      ],
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
      Navigator.of(context).popUntil((route) => route.isFirst);
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
