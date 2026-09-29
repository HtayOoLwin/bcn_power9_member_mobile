import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'member_registration_service.dart';

class MemberRegistrationPage extends StatefulWidget {
  const MemberRegistrationPage({super.key});

  @override
  State<MemberRegistrationPage> createState() => _MemberRegistrationPageState();
}

class _MemberRegistrationPageState extends State<MemberRegistrationPage> {
  static const green = Color(0xFF006B50);
  static const mint = Color(0xFFE6F5EF);

  static const Map<String, List<String>> nrcTownships = {
    '1': ['KAPATA', 'KHAPANA', 'MAPATA', 'MAPANA', 'WAMANA'],
    '2': ['BALAKHA', 'DAMASA', 'LACANA', 'PHASANA', 'YATANA'],
    '3': ['BAANA', 'KAKAYA', 'KADANA', 'KASAKA', 'LATHANA', 'THATANA'],
    '4': ['HAKHANA', 'KAPALA', 'MATANA', 'PALAWA', 'TATANA', 'TAZANA'],
    '5': ['AYATA', 'BAMANA', 'KALANA', 'KATHANA', 'MAMANA', 'SAKANA', 'YAMAPA'],
    '6': ['KATHANA', 'KASANA', 'LATANA', 'MATANA', 'THAYAKHA'],
    '7': ['BAMANA', 'KAPAKA', 'KAWANA', 'LATANA', 'NATALA', 'PAMANA', 'YAKANA'],
    '8': ['AHLANA', 'GAGANA', 'KAMANA', 'MATANA', 'MINANA', 'PAKHANA', 'SATAYA'],
    '9': ['AMAYA', 'KAPATA', 'MAHAMA', 'MAKANA', 'MATAYA', 'PATAYA', 'TAKANA'],
    '10': ['BALANA', 'KAMAYA', 'KATHANA', 'MALAMA', 'THAPHAYA', 'YAMANA'],
    '11': ['KAPHANA', 'KATANA', 'MAPANA', 'MATANA', 'SATANA', 'YATHATA'],
    '12': ['AHLANA', 'BATAHTA', 'DAGANA', 'DAGASA', 'KAMANA', 'KAMAYA', 'LAMANA', 'MAYAKA', 'PABATA', 'TAKANA', 'YAKANA'],
    '13': ['HAHANA', 'KAHANA', 'KAKHANA', 'KALANA', 'LATANA', 'MAHAYA', 'TAYANA'],
    '14': ['AMANA', 'BATHALA', 'DADAYA', 'HATHATA', 'KAKHANA', 'LAMANA', 'MAPANA', 'PATANA'],
  };

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final idNumber = TextEditingController();
  final nrcNumber = TextEditingController();

  String? gender;
  String? nationality;
  String? idType;
  String? nrcState;
  String? nrcTownship;
  String nrcCitizenType = 'N';
  String memberType = 'Silver';
  DateTime? dob;
  DateTime registrationDate = DateTime.now();
  final registrationService = MemberRegistrationService();
  bool isSubmitting = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    idNumber.dispose();
    nrcNumber.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
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
      memberType: memberType,
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
              child: ListView(
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
                      dropdown('Member Type *', memberType, ['Silver', 'Gold', 'Platinum'],
                          (v) => setState(() => memberType = v ?? 'Silver'),
                          required: true),
                      dateField('Registration Date *', registrationDate, () async {
                        final d = await pickDate(registrationDate);
                        if (d != null) setState(() => registrationDate = d);
                      }),
                    ],
                  ),
                ],
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
    final townships = nrcState == null ? <String>[] : (nrcTownships[nrcState] ?? <String>[]);

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
              keyboardType: TextInputType.number,
              maxLength: 6,
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
