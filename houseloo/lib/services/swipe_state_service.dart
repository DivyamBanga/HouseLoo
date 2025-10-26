class SwipeStateService {
  // Singleton pattern
  static final SwipeStateService _instance = SwipeStateService._internal();
  factory SwipeStateService() => _instance;
  SwipeStateService._internal();

  // Store the current swipe position
  int _currentIndex = 0;

  // Getters and setters
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  void reset() {
    _currentIndex = 0;
  }
}
