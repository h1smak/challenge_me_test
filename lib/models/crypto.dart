class Crypto {
  final String id, name, symbol, image;
  final double currentPrice;
  final List<dynamic> sparkline;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.sparkline,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      currentPrice: json['current_price'].toDouble(),
      sparkline: json['sparkline_in_7d']['price'],
    );
  }
}
