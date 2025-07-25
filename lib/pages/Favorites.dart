import 'package:crytoapp/models/Cryptocurrency.dart';
import 'package:crytoapp/providers/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/CryptoListTile.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  bool _isGridView = false;
  String _sortBy = 'name'; // name, price, change

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        List<CryptoCurrency> favorites = marketProvider.markets
            .where((element) => element.isFavorite == true)
            .toList();

        // Sort favorites based on selected criteria
        _sortFavorites(favorites);

        if (favorites.isNotEmpty) {
          return Column(
            children: [
              // Header with controls
              _buildFavoritesHeader(favorites.length),

              // Favorites list/grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await marketProvider.fetchData();
                  },
                  child: _isGridView
                    ? _buildGridView(favorites)
                    : _buildListView(favorites),
                ),
              ),
            ],
          );
        } else {
          return _buildEmptyState();
        }
      },
    );
  }

  void _sortFavorites(List<CryptoCurrency> favorites) {
    switch (_sortBy) {
      case 'name':
        favorites.sort((a, b) => a.name!.compareTo(b.name!));
        break;
      case 'price':
        favorites.sort((a, b) => (b.currentPrice ?? 0).compareTo(a.currentPrice ?? 0));
        break;
      case 'change':
        favorites.sort((a, b) => (b.priceChangePercentage24 ?? 0).compareTo(a.priceChangePercentage24 ?? 0));
        break;
    }
  }

  Widget _buildFavoritesHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and count
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'My Favorites',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count ${count == 1 ? 'coin' : 'coins'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Controls row
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      icon: const Icon(Icons.sort_rounded),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                        DropdownMenuItem(value: 'price', child: Text('Sort by Price')),
                        DropdownMenuItem(value: 'change', child: Text('Sort by Change')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isGridView = false;
                        });
                      },
                      icon: Icon(
                        Icons.list_rounded,
                        color: !_isGridView
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      ),
                      tooltip: 'List View',
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isGridView = true;
                        });
                      },
                      icon: Icon(
                        Icons.grid_view_rounded,
                        color: _isGridView
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      ),
                      tooltip: 'Grid View',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<CryptoCurrency> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        CryptoCurrency currentCrypto = favorites[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: CryptoListTile(currentCrypto: currentCrypto),
        );
      },
    );
  }

  Widget _buildGridView(List<CryptoCurrency> favorites) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        CryptoCurrency currentCrypto = favorites[index];
        return _buildFavoriteCard(currentCrypto);
      },
    );
  }

  Widget _buildFavoriteCard(CryptoCurrency crypto) {
    final changePercentage = crypto.priceChangePercentage24 ?? 0.0;
    final isPositive = changePercentage >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushNamed(context, '/details', arguments: crypto.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with logo and favorite button
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(crypto.image!),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            marketProvider.removeFavorite(crypto);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${crypto.name} removed from favorites'),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Crypto name and symbol
                    Text(
                      crypto.name!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      crypto.symbol!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Price
                    Text(
                      crypto.getFormattedPrice(marketProvider.selectedCurrency),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Price change
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Start adding cryptocurrencies to your favorites\nby tapping the heart icon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              // Navigate to markets tab
              DefaultTabController.of(context)?.animateTo(0);
            },
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Explore Markets'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
