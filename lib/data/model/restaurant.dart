class Restaurant {
  String id;
  String name;
  String description;
  String pictureId;
  String city;
  double rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": String id,
        "name": String name,
        "description": String description,
        "pictureId": String pictureId,
        "city": String city,
        "rating": num rating,
      } =>
        Restaurant(
          id: id,
          name: name,
          description: description,
          pictureId: pictureId,
          city: city,
          rating: rating.toDouble(),
        ),
      _ => throw Exception('Invalid JSON format for Restaurant'),
    };
  }
}
