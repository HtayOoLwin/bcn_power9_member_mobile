import 'package:flutter/material.dart';

class MemberRegistrationPage extends StatefulWidget {
  const MemberRegistrationPage({super.key});

  @override
  State<MemberRegistrationPage> createState() => _MemberRegistrationPageState();
}

class _MemberRegistrationPageState extends State<MemberRegistrationPage> {
  static const green = Color(0xFF006B50);
  static const mint = Color(0xFFE6F5EF);

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final idNumber = TextEditingController();

  String? gender;
  String? nationality;
  String? idType;
  String memberType = 'Silver';
  DateTime? dob;
  DateTime registrationDate = DateTime.now();

  @override
  void dispose() {
    name.dispose(); phone.dispose(); email.dispose(); address.dispose(); idNumber.dispose();
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

  void createMember() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member API will be connected next.')),
    );
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
                      dropdown('ID Type *', idType, ['NRC', 'Passport', 'Other'],
                        (v) => setState(() => idType = v), required: true),
                      textField(idNumber, 'ID Number *', required: true),
                    ],
                  ),
                  section(
                    Icons.groups_rounded,
                    'Membership Information',
                    [
                      dropdown('Member Type *', memberType, ['Silver', 'Gold', 'Platinum'],
                        (v) => setState(() => memberType = v ?? 'Silver'), required: true),
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
                        onPressed: createMember,
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Text('Create Member', style: TextStyle(fontWeight: FontWeight.w700)),
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
                Text(title, style: const TextStyle(color: Color(0xFF073F35), fontSize: 18, fontWeight: FontWeight.w800)),
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
      ValueChanged<String?> onChanged, {bool required = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: input(label),
      hint: const Text('Select'),
      items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: onChanged,
      validator: required ? (v) => v == null || v.isEmpty ? '${label.replaceAll(' *', '')} is required.' : null : null,
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
