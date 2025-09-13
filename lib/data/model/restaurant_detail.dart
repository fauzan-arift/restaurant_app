import 'package:restaurant_app/data/model/category.dart';
import 'package:restaurant_app/data/model/customer_review.dart';
import 'package:restaurant_app/data/model/menus.dart';

class RestaurantDetail {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final List<Category> categories;
  final Menus menus;
  final double rating;
  final List<CustomerReview> customerReviews;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.categories,
    required this.menus,
    required this.rating,
    required this.customerReviews,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      pictureId: json['pictureId'],
      categories: List<Category>.from(
        json['categories'].map((x) => Category.fromJson(x)),
      ),
      menus: Menus.fromJson(json['menus']),
      rating: (json['rating'] as num).toDouble(),
      customerReviews: List<CustomerReview>.from(
        json['customerReviews'].map((x) => CustomerReview.fromJson(x)),
      ),
    );
  }

  RestaurantDetail copyWith({
    String? id,
    String? name,
    String? description,
    List<CustomerReview>? customerReviews,
  }) {
    return RestaurantDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city,
      address: address,
      pictureId: pictureId,
      categories: categories,
      menus: menus,
      rating: rating,
      customerReviews: customerReviews ?? this.customerReviews,
    );
  }
}
