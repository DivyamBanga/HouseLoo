import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  final ListingService _listingService = ListingService();
  final SavedListingsService _savedService = SavedListingsService();

  List<Listing> _listings = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // Drag animation variables
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      final listings = await _listingService.loadListings();
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading listings: $e')),
        );
      }
    }
  }

  void _nextCard() {
    if (_currentIndex < _listings.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      // Calculate rotation based on horizontal drag
      _dragRotation = _dragOffset.dx / 1000;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If dragged more than 30% of screen width, trigger action
    if (_dragOffset.dx.abs() > screenWidth * 0.3) {
      if (_dragOffset.dx > 0) {
        // Swiped right - save
        _animateCardOffScreen(true);
      } else {
        // Swiped left - skip
        _animateCardOffScreen(false);
      }
    } else {
      // Return to center
      _resetCardPosition();
    }
  }

  void _animateCardOffScreen(bool isSaved) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isSaved ? screenWidth * 1.5 : -screenWidth * 1.5;

    // Save immediately if swiped right
    if (isSaved && _currentIndex < _listings.length) {
      try {
        await _savedService.saveListing(_listings[_currentIndex]);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing saved!'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save listing'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    setState(() {
      _dragOffset = Offset(targetX, _dragOffset.dy);
    });

    HapticFeedback.mediumImpact();

    // Wait for animation to complete, then move to next card
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _nextCard();
        _resetCardPosition();
      }
    });
  }

  void _resetCardPosition() {
    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0;
      _isDragging = false;
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
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _listings.isEmpty
                      ? _buildEmptyState()
                      : _currentIndex >= _listings.length
                          ? _buildEndState()
                          : _buildCardStack(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Find Your Home',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_listings.isNotEmpty && _currentIndex < _listings.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${_listings.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return Stack(
      children: [
        // Show next card in background
        if (_currentIndex + 1 < _listings.length)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Opacity(
                opacity: 0.5,
                child: ListingCard(listing: _listings[_currentIndex + 1]),
              ),
            ),
          ),
        // Current draggable card
        Positioned.fill(
          child: GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform:
                  Matrix4.translationValues(_dragOffset.dx, _dragOffset.dy, 0)
                    ..rotateZ(_dragRotation),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GestureDetector(
                      onTap: () => _showDetails(_listings[_currentIndex]),
                      child: ListingCard(listing: _listings[_currentIndex]),
                    ),
                  ),
                  // Overlay indicators
                  if (_dragOffset.dx > 50)
                    Positioned(
                      top: 100,
                      right: 50,
                      child: Transform.rotate(
                        angle: -0.3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_dragOffset.dx < -50)
                    Positioned(
                      top: 100,
                      left: 50,
                      child: Transform.rotate(
                        angle: 0.3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Text(
                            'SKIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 80, color: Colors.white70),
          SizedBox(height: 20),
          Text(
            'No listings available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'You\'ve seen all listings!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _resetCardPosition();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Start Over',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(listing: listing),
      ),
    );
  }
}
