import 'package:flutter_test/flutter_test.dart';

import 'package:tameru/app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TameruApp());
    expect(find.text('Tameru'), findsOneWidget);
  });
}
