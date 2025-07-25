class CryptoCurrency {
  String? id;
  String? symbol;
  String? name;
  String? image;
  double? currentPrice;
  double? marketCap;
  int? marketCapRank;
  double? high24;
  double? low24;
  double? priceChange24;
  double? priceChangePercentage24;
  double? circulatingSupply;
  double? ath;
  double? atl;
  bool isFavorite = false;
  String? volume;

  // Multi-currency support
  Map<String, double> prices = {};
  String currentCurrency = 'usd';

  // Coinbase integration
  double? coinbasePrice;
  double? priceDifference; // Difference between CoinGecko and Coinbase prices

  CryptoCurrency(
      {required this.id,
      required this.symbol,
      required this.name,
      required this.image,
      required this.currentPrice,
      required this.marketCap,
      required this.marketCapRank,
      required this.high24,
      required this.low24,
      required this.priceChange24,
      required this.priceChangePercentage24,
      required this.circulatingSupply,
      required this.ath,
      required this.atl});

  factory CryptoCurrency.fromJSON(Map<String, dynamic> map) {
    return CryptoCurrency(
        id: map["id"],
        symbol: map["symbol"],
        name: map["name"],
        image: map["image"],
        currentPrice: double.parse(map["current_price"].toString()),
        marketCap: double.parse(map["market_cap"].toString()),
        marketCapRank: map["market_cap_rank"],
        high24: double.parse(map["high_24h"].toString()),
        low24: double.parse(map["low_24h"].toString()),
        priceChange24: double.parse(map["price_change_24h"].toString()),
        priceChangePercentage24:
            double.parse(map["price_change_percentage_24h"].toString()),
        circulatingSupply: double.parse(map["circulating_supply"].toString()),
        ath: double.parse(map["ath"].toString()),
        atl: double.parse(map["atl"].toString()));
  }

  // Helper methods for currency formatting
  String getFormattedPrice(String currency) {
    double price = prices[currency] ?? currentPrice ?? 0.0;
    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$${price.toStringAsFixed(4)}';
      case 'inr':
        return '₹${price.toStringAsFixed(2)}';
      case 'pkr':
        return 'Rs ${price.toStringAsFixed(2)}';
      default:
        return '${price.toStringAsFixed(4)}';
    }
  }

  String getCurrencySymbol(String currency) {
    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$';
      case 'inr':
        return '₹';
      case 'pkr':
        return 'Rs ';
      default:
        return '';
    }
  }

  double getPriceForCurrency(String currency) {
    return prices[currency] ?? currentPrice ?? 0.0;
  }

  // ============ COINBASE INTEGRATION METHODS ============

  /// Get Coinbase price with currency formatting
  String getFormattedCoinbasePrice(String currency) {
    if (coinbasePrice == null) return 'N/A';

    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$${coinbasePrice!.toStringAsFixed(4)}';
      case 'inr':
        return '₹${coinbasePrice!.toStringAsFixed(2)}';
      case 'pkr':
        return 'Rs ${coinbasePrice!.toStringAsFixed(2)}';
      default:
        return coinbasePrice!.toStringAsFixed(4);
    }
  }

  /// Calculate price difference between CoinGecko and Coinbase
  double calculatePriceDifference() {
    if (coinbasePrice == null || currentPrice == null || currentPrice == 0) {
      return 0.0;
    }
    return ((coinbasePrice! - currentPrice!) / currentPrice!) * 100;
  }

  /// Get price difference as formatted string
  String getFormattedPriceDifference() {
    double diff = calculatePriceDifference();
    if (diff == 0.0) return 'N/A';

    String sign = diff > 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(2)}%';
  }

  /// Check if Coinbase price is available
  bool hasCoinbasePrice() {
    return coinbasePrice != null && coinbasePrice! > 0;
  }

  /// Get the best available price (Coinbase if available, otherwise CoinGecko)
  double getBestPrice() {
    if (hasCoinbasePrice()) {
      return coinbasePrice!;
    }
    return currentPrice ?? 0.0;
  }

  /// Get formatted best price
  String getFormattedBestPrice(String currency) {
    double price = getBestPrice();
    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$${price.toStringAsFixed(4)}';
      case 'inr':
        return '₹${price.toStringAsFixed(2)}';
      case 'pkr':
        return 'Rs ${price.toStringAsFixed(2)}';
      default:
        return price.toStringAsFixed(4);
    }
  }

  /// Get data source indicator
  String getDataSource() {
    if (hasCoinbasePrice()) {
      return 'Coinbase';
    }
    return 'CoinGecko';
  }
}
