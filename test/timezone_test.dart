import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('timezone initialization test', () {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    expect(now, isNotNull);
  });
}
