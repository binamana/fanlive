import 'package:flutter_test/flutter_test.dart';
import 'package:fanlive/main.dart';

void main() {
  testWidgets('shows main menu on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const FanLiveApp());
    await tester.pumpAndSettle();

    expect(find.text('FANLIVE'), findsOneWidget);
    expect(find.text('새로 시작'), findsOneWidget);
    expect(find.text('이어하기'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });
}
