import 'package:crytoapp/models/GraphPoint.dart';
import 'package:crytoapp/models/API.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer';

class GraphProvider with ChangeNotifier {

  List<GraphPoint> graphPoints = [];
  bool isLoading = false;
  String? errorMessage;
  String dataSource = 'CoinGecko';

  Future<void> initializeGraph(String id, int days, {String currency = 'usd', bool preferCoinbase = false}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      log('Fetching graph data for $id, $days days, currency: $currency, preferCoinbase: $preferCoinbase');

      List<dynamic> priceData;

      if (preferCoinbase) {
        priceData = await API.fetchGraphDataHybrid(id, days, currency: currency, preferCoinbase: true);
        dataSource = 'Coinbase';
      } else {
        priceData = await API.fetchGraphData(id, days, currency: currency);
        dataSource = 'CoinGecko';
      }

      log('Received ${priceData.length} data points from $dataSource');

      if (priceData.isEmpty) {
        errorMessage = 'No graph data available';
        graphPoints = [];
      } else {
        List<GraphPoint> temp = [];
        for(var pricePoint in priceData) {
          try {
            GraphPoint graphPoint = GraphPoint.fromList(pricePoint);
            temp.add(graphPoint);
          } catch (e) {
            log('Error parsing graph point: $e');
          }
        }
        graphPoints = temp;
        log('Successfully parsed ${temp.length} graph points');
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error initializing graph: $e');
      errorMessage = 'Failed to load graph data';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize graph with hybrid data (try both sources)
  Future<void> initializeGraphHybrid(String id, int days, {String currency = 'usd'}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      log('Fetching hybrid graph data for $id');

      // Try CoinGecko first
      List<dynamic> priceData = await API.fetchGraphData(id, days, currency: currency);

      if (priceData.isEmpty) {
        // Fallback to Coinbase if CoinGecko fails
        log('CoinGecko failed, trying Coinbase...');
        priceData = await API.fetchGraphDataHybrid(id, days, currency: currency, preferCoinbase: true);
        dataSource = 'Coinbase (Fallback)';
      } else {
        dataSource = 'CoinGecko';
      }

      if (priceData.isEmpty) {
        errorMessage = 'No graph data available from any source';
        graphPoints = [];
      } else {
        List<GraphPoint> temp = [];
        for(var pricePoint in priceData) {
          try {
            GraphPoint graphPoint = GraphPoint.fromList(pricePoint);
            temp.add(graphPoint);
          } catch (e) {
            log('Error parsing graph point: $e');
          }
        }
        graphPoints = temp;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error initializing hybrid graph: $e');
      errorMessage = 'Failed to load graph data';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear graph data
  void clearGraph() {
    graphPoints = [];
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

}