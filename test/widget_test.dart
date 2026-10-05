import 'package:flutter_test/flutter_test.dart';
import 'package:j_phone/main.dart';
import 'package:j_phone/modules/home/presentation/pages/homepage.dart';

void main() {
  testWidgets('JPhone App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(Homepage), findsOneWidget);
  });
}
