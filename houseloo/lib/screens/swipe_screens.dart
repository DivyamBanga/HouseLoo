import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';
import '../services/saved_listings_service.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final ListingService _listingService = ListingService();
  final SavedListingsService _savedService = SavedListingsService();
  final CardSwiperController _controller = CardSwiperController();

  List<Listing> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final listings = await _listingService.loadListings();
    setState(() {
      _listings = listings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HouseLoo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_listings.length} homes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : _listings.isEmpty
                      ? const Center(
                          child: Text(
                            'No more listings!',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : CardSwiper(
                          controller: _controller,
                          cardsCount: _listings.length,
                          onSwipe: _onSwipe,
                          padding: const EdgeInsets.all(20),
                          cardBuilder: (context, index, percentThresholdX,
                              percentThresholdY) {
                            return GestureDetector(
                              onTap: () => _showDetails(_listings[index]),
                              child: ListingCard(listing: _listings[index]),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.left),
                  ),
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: const Color(0xFFFF6B6B),
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.right),
                    size: 70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }

  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      _savedService.saveListing(_listings[previousIndex]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to favorites!'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
    }
    return true;
  }

  void _showDetails(Listing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }
}
