import 'package:flutter_test/flutter_test.dart';
import 'package:uber_clone/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash screen shows Uber text', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MyApp());
    expect(find.text('Uber'), findsOneWidget);
  });
}
