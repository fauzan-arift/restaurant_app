import 'package:restaurant_app/data/model/item.dart';

class Menus {
  final List<Item> foods;
  final List<Item> drinks;

  Menus({required this.foods, required this.drinks});

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods: List<Item>.from(json['foods'].map((x) => Item.fromJson(x))),
      drinks: List<Item>.from(json['drinks'].map((x) => Item.fromJson(x))),
    );
  }
}
