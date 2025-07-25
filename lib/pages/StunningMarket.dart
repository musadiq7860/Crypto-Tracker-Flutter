import 'package:crytoapp/widgets/CryptoListTile.dart';
import 'package:crytoapp/widgets/CurrencySelector.dart';
import 'package:crytoapp/widgets/MiniChart.dart';
import 'package:crytoapp/widgets/MarketOverviewChart.dart';
import 'package:crytoapp/pages/DetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Cryptocurrency.dart';
import '../providers/market_provider.dart';

class StunningMarkets extends StatefulWidget {
  const StunningMarkets({Key? key}) : super(key: key);

  @override
  State<StunningMarkets> createState() => _StunningMarketsState();
}

class _StunningMarketsState extends State<StunningMarkets> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        if (marketProvider.isLoading == true) {
          return _buildLoadingState();
        } else {
          if (marketProvider.markets.isNotEmpty) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  try {
                    await marketProvider.fetchData();
                  } catch (e) {
                    debugPrint('Error refreshing data: $e');
                  }
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // Stunning Header with Currency Selector
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),

                    // Beautiful Market Overview Chart
                    SliverToBoxAdapter(
                      child: MarketOverviewChart(
                        data: MarketDataGenerator.generateMarketOverviewData(),
                        primaryColor: Theme.of(context).primaryColor,
                        height: 180,
                      ),
                    ),

                    // Market Statistics Cards
                    SliverToBoxAdapter(
                      child: _buildMarketStats(marketProvider),
                    ),

                    // Debug Info and Spacing
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Showing ${marketProvider.markets.length} cryptocurrencies • Data: ${marketProvider.dataSource}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                // Data Source Toggle
                                GestureDetector(
                                  onTap: () {
                                    _showDataSourceDialog(context, marketProvider);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.swap_horiz_rounded,
                                          size: 14,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Switch API',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Market List with Beautiful Cards - Now properly scrollable
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            CryptoCurrency currentCrypto = marketProvider.markets[index];
                            return _buildCryptoCard(currentCrypto, index);
                          },
                          childCount: marketProvider.markets.length,
                        ),
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return _buildErrorState();
          }
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Market Data...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching real-time crypto prices',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crypto Markets',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Real-time cryptocurrency prices & analytics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const CurrencySelector(),
        ],
      ),
    );
  }

  Widget _buildMarketStats(MarketProvider marketProvider) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Coins',
              '${marketProvider.markets.length}',
              Icons.currency_bitcoin,
              const Color(0xFFFF9500),
              '🪙',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Top Gainer',
              _getTopGainer(marketProvider),
              Icons.trending_up,
              const Color(0xFF34C759),
              '📈',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Top Loser',
              _getTopLoser(marketProvider),
              Icons.trending_down,
              const Color(0xFFFF3B30),
              '📉',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String emoji) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(CryptoCurrency crypto, int index) {
    final changePercentage = crypto.priceChangePercentage24 ?? 0.0;
    final isPositive = changePercentage >= 0;
    final changeColor = isPositive ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(id: crypto.id ?? ''),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Crypto Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      (crypto.symbol ?? 'N/A').length >= 2
                          ? (crypto.symbol ?? 'N/A').substring(0, 2).toUpperCase()
                          : (crypto.symbol ?? 'N/A').toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Crypto Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crypto.name ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            (crypto.symbol ?? 'N/A').toUpperCase(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Beautiful Mini Chart
                          MiniChart(
                            data: ChartDataGenerator.generateSampleData(
                              isPositive: isPositive,
                              points: 15,
                            ),
                            color: changeColor,
                            width: 60,
                            height: 30,
                            isPositive: isPositive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price Info
                Consumer<MarketProvider>(
                  builder: (context, marketProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          crypto.getFormattedPrice(marketProvider.selectedCurrency),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'MCap: ${crypto.getCurrencySymbol(marketProvider.selectedCurrency)}${_formatMarketCap(crypto.marketCap ?? 0, marketProvider.selectedCurrency, crypto)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                        // Show Coinbase price comparison if available
                        if (crypto.hasCoinbasePrice()) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.compare_arrows_rounded,
                                size: 10,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'CB: ${crypto.getFormattedCoinbasePrice(marketProvider.selectedCurrency)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: crypto.calculatePriceDifference() >= 0
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  crypto.getFormattedPriceDifference(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: crypto.calculatePriceDifference() >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: changeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12,
                                color: changeColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${changePercentage.abs().toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: changeColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Data Available',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to fetch market data at the moment',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTopGainer(MarketProvider marketProvider) {
    if (marketProvider.markets.isEmpty) return 'N/A';

    var topGainer = marketProvider.markets.reduce((a, b) =>
        (a.priceChangePercentage24 ?? 0) > (b.priceChangePercentage24 ?? 0) ? a : b);

    return '${(topGainer.symbol ?? 'N/A').toUpperCase()} +${(topGainer.priceChangePercentage24 ?? 0).toStringAsFixed(1)}%';
  }

  String _getTopLoser(MarketProvider marketProvider) {
    if (marketProvider.markets.isEmpty) return 'N/A';

    var topLoser = marketProvider.markets.reduce((a, b) =>
        (a.priceChangePercentage24 ?? 0) < (b.priceChangePercentage24 ?? 0) ? a : b);

    return '${(topLoser.symbol ?? 'N/A').toUpperCase()} ${(topLoser.priceChangePercentage24 ?? 0).toStringAsFixed(1)}%';
  }

  String _formatMarketCap(double marketCap, String currency, CryptoCurrency crypto) {
    // Convert market cap to selected currency
    double convertedMarketCap = marketCap *
        (crypto.getPriceForCurrency(currency) / (crypto.currentPrice ?? 1));

    if (convertedMarketCap >= 1e12) {
      return '${(convertedMarketCap / 1e12).toStringAsFixed(1)}T';
    } else if (convertedMarketCap >= 1e9) {
      return '${(convertedMarketCap / 1e9).toStringAsFixed(1)}B';
    } else if (convertedMarketCap >= 1e6) {
      return '${(convertedMarketCap / 1e6).toStringAsFixed(1)}M';
    } else if (convertedMarketCap >= 1e3) {
      return '${(convertedMarketCap / 1e3).toStringAsFixed(1)}K';
    } else {
      return convertedMarketCap.toStringAsFixed(0);
    }
  }

  // ============ COINBASE INTEGRATION UI ============

  void _showDataSourceDialog(BuildContext context, MarketProvider marketProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.orange.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.api_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Choose Data Source',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your preferred cryptocurrency data provider',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Data Source Options
                _buildDataSourceOption(
                  context,
                  'CoinGecko',
                  'Comprehensive market data with 100+ cryptocurrencies',
                  Icons.trending_up_rounded,
                  Colors.green,
                  marketProvider.dataSource == 'CoinGecko',
                  () {
                    marketProvider.fetchData();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),

                _buildDataSourceOption(
                  context,
                  'Coinbase',
                  'Real-time prices from Coinbase exchange',
                  Icons.currency_bitcoin_rounded,
                  Colors.blue,
                  marketProvider.dataSource == 'Coinbase',
                  () {
                    marketProvider.fetchCoinbaseData();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),

                _buildDataSourceOption(
                  context,
                  'Hybrid (Both)',
                  'Combined data from CoinGecko + Coinbase',
                  Icons.merge_rounded,
                  Colors.purple,
                  marketProvider.dataSource.contains('Coinbase') && marketProvider.dataSource.contains('CoinGecko'),
                  () {
                    marketProvider.fetchHybridData();
                    Navigator.of(context).pop();
                  },
                ),

                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataSourceOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
            ? color.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? color
              : Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : null,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
