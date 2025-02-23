import 'package:challenge_me_test/bloc/crypto_cubit.dart';
import 'package:challenge_me_test/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCryptoCubit extends Mock implements CryptoCubit {}

void main() {
  late MockCryptoCubit mockCryptoCubit;

  setUp(() {
    mockCryptoCubit = MockCryptoCubit();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<CryptoCubit>.value(
        value: mockCryptoCubit,
        child: const HomePage(),
      ),
    );
  }

  testWidgets('Displays an error message if the list is empty.', (
    WidgetTester tester,
  ) async {
    when(() => mockCryptoCubit.state).thenReturn([]);
    when(() => mockCryptoCubit.stream).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(
      find.text("Could not fetch information. Reached API limit"),
      findsOneWidget,
    );
  });
}
