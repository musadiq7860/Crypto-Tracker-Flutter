import 'package:crytoapp/models/Cryptocurrency.dart';
import 'package:crytoapp/providers/market_provider.dart';
import 'package:crytoapp/widgets/CurrencySelector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'package:crytoapp/models/GraphPoint.dart';
import 'package:crytoapp/providers/graph_provider.dart';
import "package:syncfusion_flutter_charts/charts.dart";

class DetailsPage extends StatefulWidget {
  final String id;

  const DetailsPage({Key? key, required this.id}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Widget titleAndDetail(
      String title, String detail, CrossAxisAlignment crossAxisAlignment) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Text(
          detail,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }

  late GraphProvider graphProvider;

  int days = 1;
  List<bool> isSelected = [true, false, false, false];

  void toggleDate(int index) async {
    log("Loading graph for ${widget.id}...");

    for (int i = 0; i < isSelected.length; i++) {
      if (i == index) {
        isSelected[i] = true;
      } else {
        isSelected[i] = false;
      }
    }

    switch (index) {
      case 0:
        days = 1;
        break;
      case 1:
        days = 7;
        break;
      case 2:
        days = 28;
        break;
      case 3:
        days = 90;
        break;
      default:
        break;
    }

    // Get current market provider to check data source preference
    MarketProvider marketProvider = Provider.of<MarketProvider>(context, listen: false);
    bool preferCoinbase = marketProvider.dataSource.contains('Coinbase');

    await graphProvider.initializeGraphHybrid(widget.id, days, currency: marketProvider.selectedCurrency);

    setState(() {});

    log("Graph loaded with ${graphProvider.graphPoints.length} points from ${graphProvider.dataSource}");
  }

  void initializeInitialGraph() async {
    log("Loading Graph...");

    await graphProvider.initializeGraph(widget.id, days);
    setState(() {});

    log("Graph Loaded!");
  }

  @override
  void initState() {
    super.initState();

    graphProvider = Provider.of<GraphProvider>(context, listen: false);
    initializeInitialGraph();
  }

  @override
  void dispose() {
    super.dispose();
  
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        
        appBar: AppBar(
          title: Consumer<MarketProvider>(
            builder: (context, marketProvider, child) {
              CryptoCurrency currentCrypto = marketProvider.fetchCryptoById(widget.id);
              return Text(
                currentCrypto.name ?? 'Cryptocurrency',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          actions: [
            Consumer<MarketProvider>(
              builder: (context, marketProvider, child) {
                CryptoCurrency currentCrypto = marketProvider.fetchCryptoById(widget.id);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () {
                      if (currentCrypto.isFavorite) {
                        marketProvider.removeFavorite(currentCrypto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${currentCrypto.name} removed from favorites'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        marketProvider.addFavorite(currentCrypto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${currentCrypto.name} added to favorites'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        currentCrypto.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                        key: ValueKey(currentCrypto.isFavorite),
                        color: currentCrypto.isFavorite
                          ? Colors.red
                          : Theme.of(context).iconTheme.color,
                        size: 28,
                      ),
                    ),
                    tooltip: currentCrypto.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: ListView(
              
              children: [
                 SizedBox(
                  height: 20,
                ),
                Center(
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(10),
                    onPressed: (index) {
                      toggleDate(index);
                    },
                    children: [
                      Text("1D"),
                      Text("7D"),
                      Text("28D"),
                      Text("90D"),
                    ],
                    isSelected: isSelected,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: graphProvider.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading chart data...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : graphProvider.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                graphProvider.errorMessage!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.orange,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  toggleDate(isSelected.indexWhere((element) => element));
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : graphProvider.graphPoints.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  size: 48,
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No chart data available',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SfCartesianChart(
                              primaryXAxis: DateTimeAxis(),
                              plotAreaBorderWidth: 0,
                              series: <AreaSeries>[
                                AreaSeries<GraphPoint, dynamic>(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                  borderColor: Theme.of(context).primaryColor,
                                  borderWidth: 3,
                                  dataSource: graphProvider.graphPoints,
                                  xValueMapper: (GraphPoint graphPoint, index) =>
                                      graphPoint.date,
                                  yValueMapper: (GraphPoint graphpoint, index) =>
                                      graphpoint.price,
                                ),
                              ],
                              tooltipBehavior: TooltipBehavior(enable: true),
                            ),
                          ),
                ),

                // Data Source Indicator
                if (graphProvider.graphPoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.data_usage_rounded,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chart data: ${graphProvider.dataSource}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Consumer<MarketProvider>(
                  builder: (context, marketProvider, child) {
                    CryptoCurrency currentCrypto =
                        marketProvider.fetchCryptoById(widget.id);

                    return ListView(
                    
                                         
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          contentPadding: EdgeInsets.all(10),
                          tileColor: Color.fromARGB(19, 92, 92, 92),
                          
                          
                          leading: (
                            ClipOval(
                              child: Image.network(currentCrypto.image!),
            
                         
                            )
                          ),
                          title: Text(
                            currentCrypto.name! +
                                " (${currentCrypto.symbol!.toUpperCase()})",
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          subtitle: Consumer<MarketProvider>(
                            builder: (context, marketProvider, child) {
                              return Text(
                                currentCrypto.getFormattedPrice(marketProvider.selectedCurrency),
                                style: const TextStyle(
                                    color: Color(0xff0395eb),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                        
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price Change (24h)",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20 ,),
                            ),
                            Builder(
                              builder: (context) {
                                double priceChange =
                                    currentCrypto.priceChange24!;
                                double priceChangePercentage =
                                    currentCrypto.priceChangePercentage24!;

                                if (priceChange < 0) {
                                  // negative
                                  return Text(
                                    "${priceChangePercentage.toStringAsFixed(2)}% (${priceChange.toStringAsFixed(4)})",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 23),
                                  );
                                } else {
                                  // positive
                                  return Text(
                                    "+${priceChangePercentage.toStringAsFixed(2)}% (+${priceChange.toStringAsFixed(4)})",
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 23),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Multi-currency display
                        MultiCurrencyDisplay(
                          cryptoId: currentCrypto.id!,
                          prices: currentCrypto.prices,
                          currentPrice: currentCrypto.currentPrice!,
                          currentCurrency: currentCrypto.currentCurrency,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<MarketProvider>(
                              builder: (context, marketProvider, child) {
                                return titleAndDetail(
                                  "Market Cap",
                                  currentCrypto.getCurrencySymbol(marketProvider.selectedCurrency) +
                                      (currentCrypto.marketCap! *
                                       (currentCrypto.getPriceForCurrency(marketProvider.selectedCurrency) /
                                        (currentCrypto.currentPrice ?? 1))).toStringAsFixed(2),
                                  CrossAxisAlignment.start);
                              },
                            ),
                            titleAndDetail(
                                "Market Cap Rank",
                                "#" + currentCrypto.marketCapRank.toString(),
                                CrossAxisAlignment.end),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<MarketProvider>(
                              builder: (context, marketProvider, child) {
                                return titleAndDetail(
                                  "Low 24h",
                                  currentCrypto.getCurrencySymbol(marketProvider.selectedCurrency) +
                                      (currentCrypto.low24! *
                                       (currentCrypto.getPriceForCurrency(marketProvider.selectedCurrency) /
                                        (currentCrypto.currentPrice ?? 1))).toStringAsFixed(4),
                                  CrossAxisAlignment.start);
                              },
                            ),
                            Consumer<MarketProvider>(
                              builder: (context, marketProvider, child) {
                                return titleAndDetail(
                                  "High 24h",
                                  currentCrypto.getCurrencySymbol(marketProvider.selectedCurrency) +
                                      (currentCrypto.high24! *
                                       (currentCrypto.getPriceForCurrency(marketProvider.selectedCurrency) /
                                        (currentCrypto.currentPrice ?? 1))).toStringAsFixed(4),
                                  CrossAxisAlignment.end);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            titleAndDetail(
                                "Circulating Supply",
                                currentCrypto.circulatingSupply!
                                    .toInt()
                                    .toString(),
                                CrossAxisAlignment.start),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            titleAndDetail(
                                "All Time Low",
                                currentCrypto.atl!.toStringAsFixed(4),
                                CrossAxisAlignment.start),
                            titleAndDetail(
                                "All Time High",
                                currentCrypto.ath!.toStringAsFixed(4),
                                CrossAxisAlignment.start),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
