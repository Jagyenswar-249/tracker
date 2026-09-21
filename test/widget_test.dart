import 'package:flutter_test/flutter_test.dart';
import 'package:brim/app.dart';

void main() {
  testWidgets('BrimApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrimApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tasks'), findsWidgets);
  });
}
