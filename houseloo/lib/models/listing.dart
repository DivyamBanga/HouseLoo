class Listing {
  final String id;
  final String address;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final int sqft;
  final String imageUrl;
  final String description;
  final List<String> amenities;
  final double distance;
  final String availability;

  Listing({
    required this.id,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.imageUrl,
    required this.description,
    required this.amenities,
    required this.distance,
    required this.availability,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      address: json['address'] as String,
      price: json['price'] as int,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      sqft: json['sqft'] as int,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      distance: (json['distance'] as num).toDouble(),
      availability: json['availability'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sqft': sqft,
      'imageUrl': imageUrl,
      'description': description,
      'amenities': amenities,
      'distance': distance,
      'availability': availability,
    };
  }
}
