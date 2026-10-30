import 'package:fixa_boda/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on the welcome screen and shows the onboarding entry actions',
      (tester) async {
    await tester.pumpWidget(const FixabodaApp());

    expect(find.text('FIXABODA'), findsOneWidget);
    expect(find.text('Breakdown? Help is\nminutes away.'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}
