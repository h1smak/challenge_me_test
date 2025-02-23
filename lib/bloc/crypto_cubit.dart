import 'dart:convert';

import 'package:challenge_me_test/models/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class CryptoCubit extends Cubit<List<Crypto>> {
  CryptoCubit() : super([]);

  int page = 1;
  bool isFetching = false;

  Future<void> fetchCryptos() async {
    if (isFetching) return;
    isFetching = true;

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.coingecko.com/api/v3/coins/markets'
          '?vs_currency=usd&order=market_cap_desc&per_page=50&page=$page&sparkline=true',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newCryptos = data.map((json) => Crypto.fromJson(json)).toList();

        emit([...state, ...newCryptos]);
        page++;
      } else if (response.statusCode == 429) {
        print('Too many attempts');
      }
    } finally {
      isFetching = false;
    }
  }

  Future<List<double>> fetchPriceChart(String id, String period) async {
    final response = await http.get(
      Uri.parse(
        'https://api.coingecko.com/api/v3/coins/$id/market_chart?vs_currency=usd&days=$period',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['prices'] as List)
          .map((e) => (e[1] as num).toDouble())
          .toList();
    }
    return [];
  }
}
