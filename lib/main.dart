import 'package:challenge_me_test/bloc/crypto_cubit.dart';
import 'package:challenge_me_test/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CryptoCubit()..fetchCryptos()),
      ],
      child: MaterialApp(
        title: 'Crypto Tracker',
        theme: ThemeData.dark(),
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
