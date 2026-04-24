import 'package:flutter_test/flutter_test.dart';
import 'package:jomeni_app/main.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(const JomeniApp());
    expect(find.text('✨ Créons ton histoire !'), findsOneWidget);
  });
}
