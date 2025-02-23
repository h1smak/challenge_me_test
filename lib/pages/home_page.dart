import 'package:challenge_me_test/bloc/crypto_cubit.dart';
import 'package:challenge_me_test/models/crypto.dart';
import 'package:challenge_me_test/widgets/crypto_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<CryptoCubit>().fetchCryptos();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crypto Tracker')),
      body: BlocBuilder<CryptoCubit, List<Crypto>>(
        builder: (context, cryptos) {
          if (cryptos.isEmpty) {
            return Center(
              child: Text("Could not fetch information. Reached API limit"),
            );
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: cryptos.length,
            itemBuilder: (context, index) {
              final crypto = cryptos[index];
              final priceChange =
                  crypto.sparkline.isNotEmpty
                      ? crypto.sparkline.last - crypto.sparkline.first
                      : 0;
              final priceChangePercent =
                  priceChange / crypto.sparkline.first * 100;
              final isPositive = priceChange >= 0;
              final graphColor = isPositive ? Colors.green : Colors.red;

              return CryptoTile(
                crypto: crypto,
                graphColor: graphColor,
                priceChangePercent: priceChangePercent,
              );
            },
          );
        },
      ),
    );
  }
}
