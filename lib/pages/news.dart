import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:readmore/readmore.dart';

class CryptoNewsList extends StatefulWidget {
  const CryptoNewsList({Key? key}) : super(key: key);

  @override
  _CryptoNewsListState createState() => _CryptoNewsListState();
}

class _CryptoNewsListState extends State<CryptoNewsList> {
  List<dynamic> newsItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getNews();
  }

  Future<void> getNews() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Using NewsAPI for crypto news
      var response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=cryptocurrency&sortBy=publishedAt&apiKey=YOUR_API_KEY'
      ));

      if (response.statusCode == 200) {
        String jsonBody = response.body;
        Map<String, dynamic> items = jsonDecode(jsonBody);

        // Convert NewsAPI format to our format
        List<dynamic> articles = items['articles'] ?? [];
        newsItems = articles.take(20).map((article) => {
          'heading': article['title'] ?? 'No Title',
          'description': article['description'] ?? 'No Description',
          'imageURL': article['urlToImage'] ?? 'https://via.placeholder.com/300x200',
          'source': article['source']['name'] ?? 'Unknown Source',
          'url': article['url'] ?? ''
        }).toList();
      } else {
        // Fallback to mock data if API fails
        newsItems = _getMockNews();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching news: $e');
      // Use mock data as fallback
      newsItems = _getMockNews();
      setState(() {
        isLoading = false;
        errorMessage = 'Using offline news data';
      });
    }
  }

  List<dynamic> _getMockNews() {
    return [
      {
        'heading': 'Bitcoin Reaches New All-Time High in 2024',
        'description': 'Bitcoin continues its upward trajectory as institutional adoption increases worldwide. Major corporations and investment funds are adding BTC to their portfolios, driving unprecedented demand.',
        'imageURL': 'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=400&h=250&fit=crop&crop=center',
        'source': 'CoinDesk',
      },
      {
        'heading': 'Ethereum 2.0 Staking Rewards Surge',
        'description': 'Ethereum staking rewards see significant improvement following recent network upgrades. The transition to proof-of-stake has made ETH more attractive to long-term investors.',
        'imageURL': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400&h=250&fit=crop&crop=center',
        'source': 'Ethereum Foundation',
      },
      {
        'heading': 'DeFi Market Explodes with \$200B TVL',
        'description': 'Decentralized Finance protocols continue to attract billions in total value locked. New innovative protocols are launching daily, revolutionizing traditional finance.',
        'imageURL': 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=400&h=250&fit=crop&crop=center',
        'source': 'DeFi Pulse',
      },
      {
        'heading': 'Central Banks Explore Digital Currencies',
        'description': 'Major central banks worldwide are accelerating their research into Central Bank Digital Currencies (CBDCs), with several pilot programs already underway.',
        'imageURL': 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=250&fit=crop&crop=center',
        'source': 'Reuters',
      },
      {
        'heading': 'NFT Market Shows Signs of Recovery',
        'description': 'After a challenging period, the NFT market is showing signs of recovery with new utility-focused projects gaining traction among collectors and investors.',
        'imageURL': 'https://images.unsplash.com/photo-1640161704729-cbe966a08476?w=400&h=250&fit=crop&crop=center',
        'source': 'NFT News',
      },
      {
        'heading': 'Crypto Regulation Framework Advances',
        'description': 'Governments worldwide are making progress on comprehensive cryptocurrency regulation frameworks, providing much-needed clarity for the industry.',
        'imageURL': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400&h=250&fit=crop&crop=center',
        'source': 'Bloomberg',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: getNews,
      child: newsItems.isEmpty
        ? _buildEmptyState()
        : CustomScrollView(
            slivers: [
              // Beautiful Header
              SliverToBoxAdapter(
                child: _buildNewsHeader(),
              ),

              // News Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      CryptoNewsObject newsItem = CryptoNewsObject(
                        heading: newsItems[index]["heading"],
                        imageUrl: newsItems[index]["imageURL"],
                        source: newsItems[index]["source"],
                        description: newsItems[index]["description"],
                      );
                      return _buildStunningNewsCard(newsItem, index);
                    },
                    childCount: newsItems.length,
                  ),
                ),
              ),
            ],
          ),
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
            'Loading Latest News...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching crypto market updates',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connection Issue',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: getNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.newspaper_rounded,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No News Available',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsHeader() {
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
              Icons.newspaper_rounded,
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
                  'Crypto News',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Latest updates from the crypto world',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fiber_new_rounded,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStunningNewsCard(CryptoNewsObject newsItem, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Handle news item tap
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Beautiful Image with Overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          newsItem.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_rounded,
                                  size: 50,
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Source Badge
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          newsItem.source,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsItem.heading,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        newsItem.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Just now',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Trending',
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CryptoNewsObject {
  final String heading;
  final String imageUrl;
  final String source;
  final String description;
  CryptoNewsObject(
      {required this.heading,
      required this.imageUrl,
      required this.source,
      required this.description});
}