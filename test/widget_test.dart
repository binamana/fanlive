import 'package:flutter_test/flutter_test.dart';
import 'package:fanlive/main.dart';

void main() {
  testWidgets('shows character setup screen on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FanLiveApp());
    await tester.pumpAndSettle();

    expect(find.text('캐릭터 만들기'), findsOneWidget);
    expect(find.text('캐릭터 생성하기'), findsOneWidget);
  });
}