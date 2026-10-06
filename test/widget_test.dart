import 'package:flutter_test/flutter_test.dart';

import 'package:student_information_system/main.dart';

void main() {
  testWidgets('Login page is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentInformationSystem());

    expect(find.text('Student Information System 2.0'), findsOneWidget);

    expect(find.text('Login'), findsOneWidget);
  });
}
