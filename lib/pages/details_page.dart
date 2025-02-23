import 'package:challenge_me_test/bloc/crypto_cubit.dart';
import 'package:challenge_me_test/models/crypto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final Crypto crypto;

  const DetailPage({super.key, required this.crypto});

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  String selectedPeriod = '7';
  late Future<List<List<num>>> priceDataFuture;

  @override
  void initState() {
    super.initState();
    priceDataFuture = _fetchChartData();
  }

  Future<List<List<num>>> _fetchChartData() async {
    final response = await context.read<CryptoCubit>().fetchPriceChart(
      widget.crypto.id,
      selectedPeriod,
    );
    return response
        .asMap()
        .entries
        .map((e) => [e.key.toDouble(), e.value])
        .toList();
  }

  String formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(2)}K';
    } else {
      return price.toStringAsFixed(2);
    }
  }

  List<String> generateDateLabels() {
    DateTime now = DateTime.now();
    List<String> labels = [];

    if (selectedPeriod == '1') {
      for (int i = 6; i >= 0; i--) {
        labels.add(
          DateFormat.Hm().format(now.subtract(Duration(hours: i * 4))),
        );
      }
    } else if (selectedPeriod == '7') {
      for (int i = 6; i >= 0; i--) {
        labels.add(DateFormat.Md().format(now.subtract(Duration(days: i))));
      }
    } else {
      for (int i = 6; i >= 0; i--) {
        int step = (30 / 6).round();
        labels.add(
          DateFormat.Md().format(now.subtract(Duration(days: i * step))),
        );
      }
    }

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.crypto.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(widget.crypto.image, width: 80, height: 80),
            Text(
              '\$${formatPrice(widget.crypto.currentPrice)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['1', '7', '30'].map((period) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                          priceDataFuture = _fetchChartData();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedPeriod == period
                                  ? Colors.green
                                  : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          period == '1'
                              ? '1 Day'
                              : period == '7'
                              ? '7 Days'
                              : '30 Days',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 10),

            Expanded(
              child: FutureBuilder<List<List<num>>>(
                future: priceDataFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("Reached API limit. Please try again later."),
                    );
                  }

                  final prices = snapshot.data!;
                  final isPositive = prices.last[1] >= prices.first[1];
                  final graphColor = isPositive ? Colors.green : Colors.red;

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 55,
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '\$${formatPrice(value)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 40,
                              showTitles: true,
                              interval: (prices.length / 6).toDouble(),
                              getTitlesWidget: (value, meta) {
                                List<String> labels = generateDateLabels();

                                int index = (value / (prices.length / 6))
                                    .round()
                                    .clamp(0, labels.length - 1);

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    labels[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots:
                                prices
                                    .map(
                                      (e) => FlSpot(
                                        e[0].toDouble(),
                                        e[1].toDouble(),
                                      ),
                                    )
                                    .toList(),
                            isCurved: true,
                            color: graphColor,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
