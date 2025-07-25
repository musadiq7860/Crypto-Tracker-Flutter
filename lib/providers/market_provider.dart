import 'dart:async';
import 'dart:developer';

import 'package:crytoapp/models/API.dart';
import 'package:crytoapp/models/Cryptocurrency.dart';
import 'package:crytoapp/models/LocalStorage.dart';
import 'package:flutter/cupertino.dart';

class MarketProvider with ChangeNotifier {
  bool isLoading = true;
  List<CryptoCurrency> markets = [];
  String selectedCurrency = 'usd';
  Map<String, List<dynamic>> allMarketsData = {};

  // Coinbase integration
  Map<String, double> coinbasePrices = {};
  bool useCoinbaseData = false;
  String dataSource = 'CoinGecko';
  DateTime? lastCoinbaseUpdate;

  MarketProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // First try to get data for the selected currency
      List<dynamic> marketsData = await API.getMarketsForCurrency(selectedCurrency);
      List<String> favorites = await LocalStorage.fetchFavorites();

      List<CryptoCurrency> temp = [];
      for (var market in marketsData) {
        CryptoCurrency newCrypto = CryptoCurrency.fromJSON(market);
        newCrypto.currentCurrency = selectedCurrency;
        if (favorites.contains(newCrypto.id!)) {
          newCrypto.isFavorite = true;
        }
        temp.add(newCrypto);
      }
      markets = temp;
      isLoading = false;
      notifyListeners();

      // Then fetch all currencies in background for conversion
      _fetchAllCurrencies();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAllCurrencies() async {
    try {
      allMarketsData = await API.getMarkets();
      _updatePricesWithAllCurrencies();
    } catch (e) {
      // Silently fail, main currency data is already loaded
    }
  }

  void _updatePricesWithAllCurrencies() {
    for (var crypto in markets) {
      // Update prices for all currencies
      for (String currency in ['usd', 'inr', 'pkr']) {
        if (allMarketsData.containsKey(currency)) {
          var currencyData = allMarketsData[currency]!;
          var matchingCrypto = currencyData.firstWhere(
            (item) => item['id'] == crypto.id,
            orElse: () => null,
          );
          if (matchingCrypto != null) {
            crypto.prices[currency] = double.parse(matchingCrypto['current_price'].toString());
          }
        }
      }
    }
    notifyListeners();
  }

  void changeCurrency(String newCurrency) {
    if (selectedCurrency != newCurrency) {
      selectedCurrency = newCurrency;
      isLoading = true;
      notifyListeners();
      fetchData();
    }
  }

  CryptoCurrency fetchCryptoById(String id) {
    CryptoCurrency crypto =
        markets.where((element) => element.id == id).toList()[0];
    return crypto;
  }

  void addFavorite(CryptoCurrency crypto) async {
    int indexOfCrypto = markets.indexOf(crypto);
    markets[indexOfCrypto].isFavorite = true;
    await LocalStorage.addFavorite(crypto.id!);
    notifyListeners();
  }

  void removeFavorite(CryptoCurrency crypto) async {
    int indexOfCrypto = markets.indexOf(crypto);
    markets[indexOfCrypto].isFavorite = false;
    await LocalStorage.removeFavorite(crypto.id!);
    notifyListeners();
  }

  // Bulk favorites operations
  void addMultipleFavorites(List<CryptoCurrency> cryptos) async {
    for (var crypto in cryptos) {
      int indexOfCrypto = markets.indexOf(crypto);
      if (indexOfCrypto != -1) {
        markets[indexOfCrypto].isFavorite = true;
        await LocalStorage.addFavorite(crypto.id!);
      }
    }
    notifyListeners();
  }

  void removeMultipleFavorites(List<CryptoCurrency> cryptos) async {
    for (var crypto in cryptos) {
      int indexOfCrypto = markets.indexOf(crypto);
      if (indexOfCrypto != -1) {
        markets[indexOfCrypto].isFavorite = false;
        await LocalStorage.removeFavorite(crypto.id!);
      }
    }
    notifyListeners();
  }

  void clearAllFavorites() async {
    for (var crypto in markets) {
      if (crypto.isFavorite) {
        crypto.isFavorite = false;
        await LocalStorage.removeFavorite(crypto.id!);
      }
    }
    notifyListeners();
  }

  // Get favorites list
  List<CryptoCurrency> getFavorites() {
    return markets.where((crypto) => crypto.isFavorite).toList();
  }

  // Check if crypto is favorite by ID
  bool isFavoriteById(String id) {
    try {
      CryptoCurrency crypto = markets.firstWhere((element) => element.id == id);
      return crypto.isFavorite;
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status
  void toggleFavorite(CryptoCurrency crypto) {
    if (crypto.isFavorite) {
      removeFavorite(crypto);
    } else {
      addFavorite(crypto);
    }
  }

  // ============ COINBASE INTEGRATION ============

  /// Toggle between CoinGecko and Coinbase data sources
  void toggleDataSource() {
    useCoinbaseData = !useCoinbaseData;
    dataSource = useCoinbaseData ? 'Coinbase' : 'CoinGecko';
    notifyListeners();

    // Refresh data with new source
    if (useCoinbaseData) {
      fetchCoinbaseData();
    } else {
      fetchData();
    }
  }

  /// Fetch data using hybrid approach (CoinGecko + Coinbase)
  Future<void> fetchHybridData() async {
    try {
      isLoading = true;
      notifyListeners();

      Map<String, dynamic> hybridData = await API.getHybridMarketData(selectedCurrency);
      List<dynamic> marketsData = hybridData['markets'];
      coinbasePrices = Map<String, double>.from(hybridData['coinbase_prices'] ?? {});

      List<String> favorites = await LocalStorage.fetchFavorites();

      List<CryptoCurrency> temp = [];
      for (var market in marketsData) {
        CryptoCurrency newCrypto = CryptoCurrency.fromJSON(market);
        newCrypto.currentCurrency = selectedCurrency;

        // Add Coinbase price if available
        if (coinbasePrices.containsKey(newCrypto.id)) {
          newCrypto.coinbasePrice = coinbasePrices[newCrypto.id!];
        }

        if (favorites.contains(newCrypto.id!)) {
          newCrypto.isFavorite = true;
        }
        temp.add(newCrypto);
      }

      markets = temp;
      dataSource = 'CoinGecko + Coinbase';
      lastCoinbaseUpdate = DateTime.now();
      isLoading = false;
      notifyListeners();

    } catch (e) {
      isLoading = false;
      notifyListeners();
      log('Error fetching hybrid data: $e');
    }
  }

  /// Fetch data primarily from Coinbase
  Future<void> fetchCoinbaseData() async {
    try {
      isLoading = true;
      notifyListeners();

      // Get basic market data from CoinGecko for structure
      List<dynamic> marketsData = await API.getMarketsForCurrency(selectedCurrency);

      // Get prices from Coinbase for top cryptocurrencies
      List<String> topCryptoIds = marketsData.take(20).map((e) => e['id'].toString()).toList();
      coinbasePrices = await API.getCoinbasePrices(
        topCryptoIds,
        currency: API.currencyMapping[selectedCurrency] ?? 'USD'
      );

      List<String> favorites = await LocalStorage.fetchFavorites();

      List<CryptoCurrency> temp = [];
      for (var market in marketsData) {
        CryptoCurrency newCrypto = CryptoCurrency.fromJSON(market);
        newCrypto.currentCurrency = selectedCurrency;

        // Use Coinbase price if available, otherwise use CoinGecko
        if (coinbasePrices.containsKey(newCrypto.id)) {
          newCrypto.currentPrice = coinbasePrices[newCrypto.id!];
          newCrypto.coinbasePrice = coinbasePrices[newCrypto.id!];
        }

        if (favorites.contains(newCrypto.id!)) {
          newCrypto.isFavorite = true;
        }
        temp.add(newCrypto);
      }

      markets = temp;
      dataSource = 'Coinbase';
      lastCoinbaseUpdate = DateTime.now();
      isLoading = false;
      notifyListeners();

    } catch (e) {
      isLoading = false;
      notifyListeners();
      log('Error fetching Coinbase data: $e');
      // Fallback to CoinGecko
      fetchData();
    }
  }

  /// Get Coinbase spot price for a specific crypto
  Future<double> getCoinbaseSpotPrice(String cryptoSymbol) async {
    try {
      return await API.getCoinbaseSpotPrice(
        cryptoSymbol,
        currency: API.currencyMapping[selectedCurrency] ?? 'USD'
      );
    } catch (e) {
      log('Error getting Coinbase spot price: $e');
      return 0.0;
    }
  }

  /// Update prices with latest Coinbase data
  Future<void> updateCoinbasePrices() async {
    if (markets.isEmpty) return;

    try {
      List<String> cryptoIds = markets.take(10).map((e) => e.id!).toList();
      Map<String, double> latestPrices = await API.getCoinbasePrices(
        cryptoIds,
        currency: API.currencyMapping[selectedCurrency] ?? 'USD'
      );

      for (var crypto in markets) {
        if (latestPrices.containsKey(crypto.id)) {
          crypto.coinbasePrice = latestPrices[crypto.id!];
          if (useCoinbaseData) {
            crypto.currentPrice = latestPrices[crypto.id!];
          }
        }
      }

      coinbasePrices.addAll(latestPrices);
      lastCoinbaseUpdate = DateTime.now();
      notifyListeners();

    } catch (e) {
      log('Error updating Coinbase prices: $e');
    }
  }
}
