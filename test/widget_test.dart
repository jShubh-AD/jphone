import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_phone/main.dart';
import 'package:j_phone/modules/home/presentation/pages/homepage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.io/videoPlayer'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'init') {
          return null;
        }
        if (methodCall.method == 'create') {
          return {'textureId': 1};
        }
        return null;
      },
    );
  });

  testWidgets('JPhone App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(Homepage), findsOneWidget);
  });
}
