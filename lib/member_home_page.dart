import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'member_dashboard_service.dart';
import 'member_history_service.dart';
import 'member_card_service.dart';
import 'membership_card_page.dart';
import 'about_page.dart';

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

class _MemberHomePageState extends State<MemberHomePage> with WidgetsBindingObserver {
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
  MemberCardData? _profileCard;
  bool _profileLoading = false;
  String? _profileError;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboard();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshActivePage(silent: true),
    );
  }

  Future<void> _refreshActivePage({bool silent = false}) async {
    if (!mounted) return;

    switch (_index) {
      case 0:
        await _loadDashboard(silent: silent);
        break;
      case 1:
        // MembershipCardPage has its own 5-second refresh timer.
        break;
      case 2:
        await _loadHistory(silent: silent);
        await _loadDashboard(silent: true);
        break;
      case 3:
        await _loadProfile(silent: silent);
        await _loadDashboard(silent: true);
        break;
    }
  }

  void _changePage(int value) {
    if (_index == value) {
      _refreshActivePage();
      return;
    }
    setState(() => _index = value);
    _refreshActivePage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshActivePage();
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

  Future<void> _loadDashboard({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    final result = await MemberDashboardService(widget.authService).load();
    if (!mounted) return;
    setState(() {
      if (!silent) _loading = false;
      if (result.success) {
        _data = result.data;
        _loadError = null;
      } else if (!silent) {
        _loadError = result.message;
      }
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
            MembershipCardPage(authService: widget.authService),
            _history(),
            _profile(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _changePage,
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
          onTap: () => _changePage(2),
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
              onPressed: () => _changePage(2),
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
            final date =
                '${_hApiDate(tx.postingDate)}  ${_hTime(tx.postingTime)}';
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
    return "${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}";
  }

  String _hApiDate(String v) { final d = DateTime.tryParse(v); return d == null ? v : _hDate(d); }
  String _hTime(String v) {
    final p = v.split(':'); if (p.length < 2) return v;
    final s = p.length > 2 ? p[2].split('.').first.padLeft(2, '0') : '00';
    return "${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}:$s";
  }

  Future<void> _loadHistory({bool silent = false}) async {
    if (_fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!)) {
      if (!silent) {
        setState(() => _historyError = 'From Date cannot be after To Date.');
      }
      return;
    }
    if (!silent && mounted) {
      setState(() { _historyLoading = true; _historyError = null; });
    }
    final direction = _historyTab == 1 ? 'Earn' : (_historyTab == 2 ? 'Redeem' : null);
    final r = await MemberHistoryService(widget.authService).load(fromDate: _fromDate, toDate: _toDate, direction: direction);
    if (!mounted) return;
    setState(() {
      if (!silent) _historyLoading = false;
      if (r.success) {
        _historyError = null;
        _historyRows = r.transactions;
      } else if (!silent) {
        _historyError = r.message;
      }
    });
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
        const SizedBox(height: 16), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0AA77B),Color(0xFF08745C)]), borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.stars_rounded,color: Colors.white), const SizedBox(width: 10), const Expanded(child: Text('Current Points',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700))), Text('${_points(_data?.profile.currentPointBalance ?? 0)} pts',style: const TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w900))])),
        const SizedBox(height: 18), Row(children: [const Expanded(child: Text('Transactions',style: TextStyle(fontSize:17,fontWeight:FontWeight.w900))), Text('${_historyRows.length} records',style: const TextStyle(color:Color(0xFF7A8782),fontSize:11))]), const SizedBox(height: 8),
        if (_historyLoading) const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: green))
        else if (_historyError != null) Column(children:[Text(_historyError!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.redAccent)),TextButton(onPressed:_loadHistory,child:const Text('Retry'))])
        else if (_historyRows.isEmpty) const Padding(padding:EdgeInsets.all(30),child:Text('No point history found.',style:TextStyle(color:Color(0xFF718092))))
        else ..._historyRows.map((tx) { final earned=tx.earned; return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFE4EAE7))),child:Row(children:[CircleAvatar(radius:20,backgroundColor:earned?const Color(0xFFE1F6E9):const Color(0xFFFDE8E8),child:Icon(earned?Icons.add_rounded:Icons.remove_rounded,color:earned?const Color(0xFF079447):const Color(0xFFD92D20))),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(earned?'Points Added':'Points Redeemed',style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:3),Text('${_hApiDate(tx.postingDate)}  ${_hTime(tx.postingTime)}',style:const TextStyle(color:Color(0xFF7A8782),fontSize:11))])),Text('${earned ? '+ ' : '- '}${_points(tx.points)}',style:TextStyle(color:earned?const Color(0xFF079447):const Color(0xFFD92D20),fontSize:16,fontWeight:FontWeight.w900))])); })
      ]))
    ]));
  }
  Future<void> _loadProfile({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() { _profileLoading = true; _profileError = null; });
    }
    final result = await MemberCardService(widget.authService).load();
    if (!mounted) return;
    setState(() {
      if (!silent) _profileLoading = false;
      if (result.success) {
        _profileCard = result.data;
        _profileError = null;
      } else if (!silent) {
        _profileError = result.message;
      }
    });
  }

  Widget _profile() {
    if (_profileLoading) return const Center(child: CircularProgressIndicator(color: green));
    if (_profileError != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_profileError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 8),
        TextButton(onPressed: _loadProfile, child: const Text('Retry')),
      ]));
    }
    final p = _profileCard;
    return RefreshIndicator(
      color: green,
      onRefresh: _loadProfile,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF087044), darkGreen])),
            child: const Text('Profile', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00543C), Color(0xFF078452), Color(0xFF004D39)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const CircleAvatar(radius: 39, backgroundColor: Color(0xFFE8F6F0),
                    child: Icon(Icons.person_rounded, color: green, size: 48)),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p?.memberName.isNotEmpty == true ? p!.memberName : widget.fullName,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(p?.memberId ?? '-', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFEAA0), Color(0xFFE8BE55)]),
                        borderRadius: BorderRadius.circular(18)),
                      child: Text('${p?.memberType.isNotEmpty == true ? p!.memberType : 'Member'} Member',
                        style: const TextStyle(color: darkGreen, fontWeight: FontWeight.w900)),
                    ),
                  ])),
                  const SizedBox(width: 8),
                  Column(children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF1D16A), size: 31),
                    Text((p?.memberType ?? 'Member').toUpperCase(),
                      style: const TextStyle(color: Color(0xFFF1D16A), fontSize: 11, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xAA004632), borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const CircleAvatar(radius: 4, backgroundColor: Color(0xFF78E85B)),
                        const SizedBox(width: 5),
                        Text(p?.memberStatus.isNotEmpty == true ? p!.memberStatus : '-',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE1E8E4))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    CircleAvatar(radius: 18, backgroundColor: mint, child: Icon(Icons.person_rounded, color: green, size: 20)),
                    SizedBox(width: 10),
                    Text('Member Information', style: TextStyle(color: darkGreen, fontSize: 18, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 9),
                  _profileInfo(Icons.person_outline_rounded, 'Member Name', p?.memberName ?? widget.fullName),
                  _profileInfo(Icons.badge_outlined, 'Member ID', p?.memberId ?? '-'),
                  _profileInfo(Icons.verified_user_outlined, 'Status', p?.memberStatus ?? '-'),
                  _profileInfo(Icons.workspace_premium_outlined, 'Member Type', p?.memberType ?? '-'),
                  _profileInfo(Icons.phone_outlined, 'Phone', _data?.profile.phone ?? '-'),
                  _profileInfo(Icons.email_outlined, 'Email', _data?.profile.email ?? '-'),
                  _profileInfo(Icons.calendar_month_outlined, 'Registration Date', _profileDate(p?.registrationDate ?? '')),
                  _profileInfo(Icons.event_outlined, 'Membership Expiry Date', _profileDate(p?.expiryDate ?? '')),
                  _profileInfo(Icons.monetization_on_outlined, 'Current Point Balance', _points(p?.currentPoints ?? 0)),
                  _profileInfo(Icons.qr_code_2_rounded, 'Card Number', p?.cardNumber ?? '-'),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1E8E4))),
                child: Column(children: [
                  _profileTile(Icons.description_outlined, 'Terms & Conditions'),
                  _profileTile(
                    Icons.info_outline_rounded,
                    'About',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: Colors.white,
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
                onTap: _confirmLogout,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _profileDate(String value) {
    if (value.isEmpty) return '-';
    final d = DateTime.tryParse(value);
    return d == null ? value : _hDate(d);
  }

  Widget _profileInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEDF0EE)))),
      child: Row(children: [
        SizedBox(width: 30, child: Icon(icon, size: 19, color: Color(0xFF53615C))),
        const SizedBox(width: 8),
        SizedBox(width: 142, child: Text(label, style: const TextStyle(color: Color(0xFF68736F), fontSize: 12))),
        Expanded(child: Text(value.isEmpty ? '-' : value,
          style: const TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.w800))),
      ]),
    );
  }

  Widget _profileTile(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Colors.white,
        leading: Icon(icon, color: darkGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
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
