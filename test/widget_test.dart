import 'package:flutter_test/flutter_test.dart';

import 'package:bcn_power9_member_mobile/main.dart';

void main() {
  test('POWER 9 member app root widget can be created', () {
    const app = Power9MemberApp();

    expect(app, isA<Power9MemberApp>());
  });
}
