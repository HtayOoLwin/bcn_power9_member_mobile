import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'member_registration_service.dart';
import 'nrc_township_codes.dart';

class MemberRegistrationPage extends StatefulWidget {
  const MemberRegistrationPage({super.key});

  @override
  State<MemberRegistrationPage> createState() => _MemberRegistrationPageState();
}

class _MemberRegistrationPageState extends State<MemberRegistrationPage> with WidgetsBindingObserver {
  static const green = Color(0xFF006B50);
  static const mint = Color(0xFFE6F5EF);


  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final idNumber = TextEditingController();
  final nrcNumber = TextEditingController();
  final nrcNumberFocusNode = FocusNode();

  String? gender;
  String? nationality;
  String? idType;
  String? nrcState;
  String? nrcTownship;
  String nrcCitizenType = 'N';
  String? memberType;
  List<String> memberTypes = const [];
  bool isLoadingMemberTypes = true;
  String? memberTypeError;
  DateTime? dob;
  DateTime registrationDate = DateTime.now();
  final registrationService = MemberRegistrationService();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadMemberTypes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      registrationDate = DateTime.now();
      loadMemberTypes();
    }
  }

  Future<void> loadMemberTypes() async {
    setState(() {
      isLoadingMemberTypes = true;
      memberTypeError = null;
    });

    final result = await registrationService.getMemberTypes();
    if (!mounted) return;

    setState(() {
      isLoadingMemberTypes = false;
      if (result.success) {
        memberTypes = result.memberTypes;
        memberType = memberTypes.isNotEmpty ? memberTypes.first : null;
      } else {
        memberTypes = const [];
        memberType = null;
        memberTypeError = result.message;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    name.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    idNumber.dispose();
    nrcNumber.dispose();
    nrcNumberFocusNode.dispose();
    super.dispose();
  }

  Future<DateTime?> pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

  String dateText(DateTime? d) {
    if (d == null) return 'dd/mm/yyyy';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get composedNrc {
    if (nrcState == null || nrcTownship == null || nrcNumber.text.length != 6) {
      return '';
    }
    return '$nrcState/$nrcTownship($nrcCitizenType)${nrcNumber.text}';
  }

  String serverDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> createMember() async {
    FocusScope.of(context).unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      if (idType == 'NRC' && nrcNumber.text.length != 6) {
        nrcNumberFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NRC Number must be exactly 6 digits. Please enter it again.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields.')),
        );
      }
      return;
    }

    if (isSubmitting) return;

    final finalIdNumber = idType == 'NRC' ? composedNrc : idNumber.text.trim();

    setState(() => isSubmitting = true);

    final result = await registrationService.register(
      memberName: name.text,
      phone: phone.text,
      email: email.text,
      gender: gender ?? '',
      nationality: nationality ?? '',
      address: address.text,
      dateOfBirth: serverDate(dob),
      idType: idType ?? '',
      idNumber: finalIdNumber,
      memberType: memberType ?? '',
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: green, size: 52),
        title: const Text('Registration Successful'),
        content: Text(
          result.memberId.isEmpty
              ? result.message
              : '${result.message}\n\nMember ID: ${result.memberId}',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(backgroundColor: green),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text('New Member'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadMemberTypes,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                children: [
                  section(
                    Icons.person_rounded,
                    'Personal Information',
                    [
                      textField(name, 'Member Name *', required: true),
                      textField(phone, 'Phone *', required: true, keyboard: TextInputType.phone),
                      dropdown('Gender', gender, ['Male', 'Female'], (v) => setState(() => gender = v)),
                      textField(email, 'Email *', required: true, keyboard: TextInputType.emailAddress),
                      dropdown('Nationality', nationality, ['Myanmar', 'Other'], (v) => setState(() => nationality = v)),
                      textField(address, 'Address', lines: 3),
                      dateField('Date Of Birth', dob, () async {
                        final d = await pickDate(dob ?? DateTime(2000));
                        if (d != null) setState(() => dob = d);
                      }),
                    ],
                  ),
                  section(
                    Icons.badge_rounded,
                    'ID Information',
                    [
                      dropdown(
                        'ID Type *',
                        idType,
                        ['NRC', 'Passport', 'Driving License', 'Other'],
                        (v) => setState(() {
                          idType = v;
                          idNumber.clear();
                          nrcState = null;
                          nrcTownship = null;
                          nrcCitizenType = 'N';
                          nrcNumber.clear();
                        }),
                        required: true,
                      ),
                      if (idType == 'NRC') ...nrcFields() else textField(idNumber, 'ID Number *', required: true),
                    ],
                  ),
                  section(
                    Icons.groups_rounded,
                    'Membership Information',
                    [
                      if (isLoadingMemberTypes)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 10),
                              Text('Loading member types...'),
                            ],
                          ),
                        )
                      else if (memberTypeError != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                memberTypeError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: loadMemberTypes,
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      else
                        dropdown(
                          'Member Type *',
                          memberType,
                          memberTypes,
                          (v) => setState(() => memberType = v),
                          required: true,
                        ),
                      readOnlyDateField('Registration Date *', registrationDate),
                    ],
                  ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: green,
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const Key('create_member_button'),
                        onPressed: isSubmitting ? null : createMember,
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Member', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> nrcFields() {
    final townships = nrcState == null ? <String>[] : nrcTownshipsForState(nrcState!);

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: dropdown(
              'State/Region *',
              nrcState,
              List.generate(14, (index) => '${index + 1}'),
              (v) => setState(() {
                nrcState = v;
                nrcTownship = null;
              }),
              required: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: dropdown(
              'Township Code *',
              nrcTownship,
              townships,
              (v) => setState(() => nrcTownship = v),
              required: true,
            ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: dropdown(
              'Type *',
              nrcCitizenType,
              const ['N', 'E', 'P', 'T'],
              (v) => setState(() => nrcCitizenType = v ?? 'N'),
              required: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: nrcNumber,
              focusNode: nrcNumberFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: input('NRC Number *').copyWith(
                counterText: '',
                hintText: '123456',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'NRC Number is required.';
                if (v.length != 6) return 'Enter 6 digits.';
                return null;
              },
            ),
          ),
        ],
      ),
      if (composedNrc.isNotEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            composedNrc,
            style: const TextStyle(
              color: green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ];
  }

  Widget section(IconData icon, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6E2)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(icon, color: green),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF073F35), fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...children.expand((w) => [w, const SizedBox(height: 12)]),
        ],
      ),
    );
  }

  Widget textField(TextEditingController controller, String label,
      {bool required = false, int lines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: keyboard,
      decoration: input(label),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? '${label.replaceAll(' *', '')} is required.' : null
          : null,
    );
  }

  Widget dropdown(String label, String? value, List<String> values,
      ValueChanged<String?> onChanged,
      {bool required = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: input(label),
      hint: const Text('Select'),
      items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: onChanged,
      validator: required
          ? (v) => v == null || v.isEmpty ? '${label.replaceAll(' *', '')} is required.' : null
          : null,
    );
  }

  Widget dateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: input(label),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 22),
            const SizedBox(width: 12),
            Text(dateText(date), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget readOnlyDateField(String label, DateTime date) {
    return InputDecorator(
      decoration: input(label).copyWith(
        filled: true,
        fillColor: const Color(0xFFF1F3F2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 22,
            color: Color(0xFF7A8580),
          ),
          const SizedBox(width: 12),
          Text(
            dateText(date),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF5F6965),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Color(0xFF7A8580),
          ),
        ],
      ),
    );
  }

  InputDecoration input(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF49504C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: green, width: 1.7),
        ),
      );
}
