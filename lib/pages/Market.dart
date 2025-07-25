import 'package:crytoapp/widgets/CryptoListTile.dart';
import 'package:crytoapp/widgets/CurrencySelector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Cryptocurrency.dart';
import '../providers/market_provider.dart';

class Markets extends StatefulWidget {
  const Markets({Key? key}) : super(key: key);

  @override
  State<Markets> createState() => _MarketsState();
}

class _MarketsState extends State<Markets> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        if (marketProvider.isLoading == true) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (marketProvider.markets.isNotEmpty) {
            return Column(
              children: [
                // Currency Selector at the top
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Currency: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const CurrencySelector(),
                    ],
                  ),
                ),
                // Market list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await marketProvider.fetchData();
                      } catch (e, stack) {
                        debugPrint('❌ Error refreshing markets: $e');
                        debugPrintStack(stackTrace: stack);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Failed to refresh data. Please try again."),
                            ),
                          );
                        }
                      }
                    },
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemCount: marketProvider.markets.length,
                      itemBuilder: (context, index) {
                        CryptoCurrency currentCrypto = marketProvider.markets[index];
                        return CryptoListTile(currentCrypto: currentCrypto);
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("Data Not Found!"));
          }
        }
      },
    );
  }
}
