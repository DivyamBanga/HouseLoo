import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/listing.dart';

class ListingService {
  Future<List<Listing>> loadListings() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/listings.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      print('Error loading listings: $e');
      return [];
    }
  }
}
