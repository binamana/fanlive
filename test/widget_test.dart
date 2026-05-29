import 'package:flutter_test/flutter_test.dart';

import 'package:fanlive/main.dart';

void main() {
  testWidgets('shows character setup on first run', (WidgetTester tester) async {
    await tester.pumpWidget(const FanLiveApp());

    expect(find.text('캐릭터 만들기'), findsOneWidget);
    expect(find.text('캐릭터 생성하기'), findsOneWidget);
  });
}
