import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: marketProvider.selectedCurrency,
              icon: const Icon(Icons.keyboard_arrow_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  marketProvider.changeCurrency(newValue);
                }
              },
              items: const [
                DropdownMenuItem<String>(
                  value: 'usd',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇺🇸'),
                      SizedBox(width: 8),
                      Text('USD'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'inr',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇮🇳'),
                      SizedBox(width: 8),
                      Text('INR'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'pkr',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇵🇰'),
                      SizedBox(width: 8),
                      Text('PKR'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MultiCurrencyDisplay extends StatelessWidget {
  final String cryptoId;
  final Map<String, double> prices;
  final double currentPrice;
  final String currentCurrency;

  const MultiCurrencyDisplay({
    Key? key,
    required this.cryptoId,
    required this.prices,
    required this.currentPrice,
    required this.currentCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price in Different Currencies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCurrencyRow('USD', 'usd', '🇺🇸', '\$'),
            const SizedBox(height: 8),
            _buildCurrencyRow('Indian Rupee', 'inr', '🇮🇳', '₹'),
            const SizedBox(height: 8),
            _buildCurrencyRow('Pakistani Rupee', 'pkr', '🇵🇰', 'Rs '),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(String name, String code, String flag, String symbol) {
    double price = prices[code] ?? currentPrice;
    bool isSelected = currentCurrency == code;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.blue, width: 1) : null,
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '$symbol${price.toStringAsFixed(code == 'usd' ? 4 : 2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : null,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
