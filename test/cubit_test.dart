import 'package:challenge_me_test/bloc/crypto_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late CryptoCubit cryptoCubit;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    cryptoCubit = CryptoCubit();
  });

  tearDown(() {
    cryptoCubit.close();
  });

  //!Passed only when you can get respons from API
  test(
    'fetchCryptos should emit a list of Crypto objects on success',
    () async {
      final responseJson = jsonEncode([
        {
          "id": "bitcoin",
          "name": "Bitcoin",
          "symbol": "btc",
          "image": "https://image.com/bitcoin.png",
          "current_price": 45000.0,
          "sparkline_in_7d": {
            "price": [44000.0, 45000.0],
          },
        },
      ]);

      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseJson, 200));

      await cryptoCubit.fetchCryptos();
      expect(cryptoCubit.state, isNotEmpty);
      expect(cryptoCubit.state.first.name, "Bitcoin");
    },
  );
}
