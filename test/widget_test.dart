import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_example/main.dart';

void main() {
  testWidgets('Renders ChatPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify if ChatPage is rendered.
    expect(find.byType(ChatPage), findsOneWidget);
  });
}
