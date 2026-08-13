import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toursandtravels/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JamalToursApp(),
      ),
    );

    expect(find.byType(JamalToursApp), findsOneWidget);
  });
}
