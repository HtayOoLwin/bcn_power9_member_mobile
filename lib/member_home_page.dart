import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'member_dashboard_service.dart';
import 'member_history_service.dart';

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
  bool _historyLoading = false;
  String? _historyError;
  List<MemberTransaction> _historyRows = const [];
  DateTime? _fromDate;
  DateTime? _toDate;
  int _historyTab = 0;

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
        onDestinationSelected: (value) { setState(() => _index = value); if (value == 2 && _historyRows.isEmpty) _loadHistory(); },
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

  String _hDate(DateTime? v) {
    if (v == null) return 'dd/mm/yyyy';
    return v.day.toString().padLeft(2, '0') + '/' + v.month.toString().padLeft(2, '0') + '/' + v.year.toString();
  }

  String _hApiDate(String v) { final d = DateTime.tryParse(v); return d == null ? v : _hDate(d); }
  String _hTime(String v) {
    final p = v.split(':'); if (p.length < 2) return v;
    final s = p.length > 2 ? p[2].split('.').first.padLeft(2, '0') : '00';
    return p[0].padLeft(2, '0') + ':' + p[1].padLeft(2, '0') + ':' + s;
  }

  Future<void> _loadHistory() async {
    if (_fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!)) { setState(() => _historyError = 'From Date cannot be after To Date.'); return; }
    setState(() { _historyLoading = true; _historyError = null; });
    final direction = _historyTab == 1 ? 'Earn' : (_historyTab == 2 ? 'Redeem' : null);
    final r = await MemberHistoryService(widget.authService).load(fromDate: _fromDate, toDate: _toDate, direction: direction);
    if (!mounted) return;
    setState(() { _historyLoading = false; _historyError = r.success ? null : r.message; if (r.success) _historyRows = r.transactions; });
  }

  Future<void> _pickHDate(bool from) async {
    final picked = await showDatePicker(context: context, initialDate: (from ? _fromDate : _toDate) ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked == null || !mounted) return;
    setState(() { if (from) { _fromDate = picked; } else { _toDate = picked; } });
  }

  Widget _hTab(String label, int value) {
    final selected = _historyTab == value;
    return Expanded(child: InkWell(onTap: () { setState(() => _historyTab = value); _loadHistory(); }, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? green : Colors.transparent, borderRadius: BorderRadius.circular(22)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : const Color(0xFF64716D), fontSize: 12, fontWeight: FontWeight.w800)))));
  }

  Widget _hDateField(String label, DateTime? value, bool from) {
    return Expanded(child: InkWell(onTap: () => _pickHDate(from), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD9E3DE))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0xFF75817D), fontSize: 10)), const SizedBox(height: 5), Row(children: [const Icon(Icons.calendar_month_rounded, color: green, size: 17), const SizedBox(width: 6), Text(_hDate(value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))])]))));
  }

  Widget _history() {
    return RefreshIndicator(color: green, onRefresh: _loadHistory, child: ListView(padding: EdgeInsets.zero, children: [
      Container(padding: const EdgeInsets.fromLTRB(16,18,16,18), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF008866), darkGreen])), child: const Text('Point History', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
      Padding(padding: const EdgeInsets.fromLTRB(16,14,16,24), child: Column(children: [
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFE9EFEC), borderRadius: BorderRadius.circular(24)), child: Row(children: [_hTab('All',0), _hTab('Point Add',1), _hTab('Point Redeem',2)])),
        const SizedBox(height: 14), Row(children: [_hDateField('From Date',_fromDate,true), const SizedBox(width: 9), _hDateField('To Date',_toDate,false)]),
        const SizedBox(height: 10), Row(children: [
          Expanded(child: FilledButton(onPressed: _loadHistory, style: FilledButton.styleFrom(backgroundColor: green), child: const Text('Apply'))), const SizedBox(width: 9),
          Expanded(child: OutlinedButton(onPressed: () { setState(() { _historyTab=0; _fromDate=null; _toDate=null; }); _loadHistory(); }, style: OutlinedButton.styleFrom(foregroundColor: green, side: const BorderSide(color: green)), child: const Text('Clear')))
        ]),
        const SizedBox(height: 16), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0AA77B),Color(0xFF08745C)]), borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.stars_rounded,color: Colors.white), const SizedBox(width: 10), const Expanded(child: Text('Current Points',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700))), Text(_points(_data?.profile.currentPointBalance ?? 0) + ' pts',style: const TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w900))])),
        const SizedBox(height: 18), Row(children: [const Expanded(child: Text('Transactions',style: TextStyle(fontSize:17,fontWeight:FontWeight.w900))), Text(_historyRows.length.toString() + ' records',style: const TextStyle(color:Color(0xFF7A8782),fontSize:11))]), const SizedBox(height: 8),
        if (_historyLoading) const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: green))
        else if (_historyError != null) Column(children:[Text(_historyError!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.redAccent)),TextButton(onPressed:_loadHistory,child:const Text('Retry'))])
        else if (_historyRows.isEmpty) const Padding(padding:EdgeInsets.all(30),child:Text('No point history found.',style:TextStyle(color:Color(0xFF718092))))
        else ..._historyRows.map((tx) { final earned=tx.earned; return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFE4EAE7))),child:Row(children:[CircleAvatar(radius:20,backgroundColor:earned?const Color(0xFFE1F6E9):const Color(0xFFFDE8E8),child:Icon(earned?Icons.add_rounded:Icons.remove_rounded,color:earned?const Color(0xFF079447):const Color(0xFFD92D20))),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(earned?'Points Added':'Points Redeemed',style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(_hApiDate(tx.postingDate)+'  '+_hTime(tx.postingTime),style:const TextStyle(color:Color(0xFF7A8782),fontSize:11))])),Text((earned?'+ ':'- ')+_points(tx.points),style:TextStyle(color:earned?const Color(0xFF079447):const Color(0xFFD92D20),fontSize:16,fontWeight:FontWeight.w900))])); })
      ]))
    ]));
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
