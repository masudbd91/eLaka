// test/performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elaka/main.dart' as app;

void main() {
  testWidgets('Performance test - startup time', (WidgetTester tester) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    // Call the main() function from your main.dart file
    // This avoids having to know the exact class name
    app.main();

    await tester.pumpAndSettle();
    stopwatch.stop();

    print('App startup time: ${stopwatch.elapsedMilliseconds}ms');

    // Verify startup time is acceptable
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  });
}
