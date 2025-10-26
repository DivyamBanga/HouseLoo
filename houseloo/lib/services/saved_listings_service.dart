import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing.dart';

class SavedListingsService {
  static const String _key = 'saved_listings';

  Future<List<Listing>> getSavedListings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_key);

    if (savedData == null) return [];

    final List<dynamic> jsonList = json.decode(savedData);
    return jsonList.map((json) => Listing.fromJson(json)).toList();
  }

  Future<void> saveListing(Listing listing) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedListings = await getSavedListings();

      if (!savedListings.any((l) => l.id == listing.id)) {
        savedListings.add(listing);
        final String jsonString =
            json.encode(savedListings.map((l) => l.toJson()).toList());
        await prefs.setString(_key, jsonString);
        print('Successfully saved listing: ${listing.id} - ${listing.address}');
      } else {
        print('Listing already saved: ${listing.id}');
      }
    } catch (e) {
      print('Error saving listing: $e');
      rethrow;
    }
  }

  Future<void> removeListing(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final savedListings = await getSavedListings();
    savedListings.removeWhere((l) => l.id == id);

    final String jsonString =
        json.encode(savedListings.map((l) => l.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<bool> isListingSaved(String id) async {
    final savedListings = await getSavedListings();
    return savedListings.any((l) => l.id == id);
  }
}
