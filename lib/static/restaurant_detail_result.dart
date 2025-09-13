import 'package:restaurant_app/data/model/restaurant_detail.dart';

sealed class RestaurantDetailResultState {}

class RestaurantDetailNoneState extends RestaurantDetailResultState {}

class RestaurantDetailLoadingState extends RestaurantDetailResultState {}

class RestaurantDetailHasDataState extends RestaurantDetailResultState {
  final RestaurantDetail restaurantDetail;

  RestaurantDetailHasDataState(this.restaurantDetail);
}

class RestaurantDetailErrorState extends RestaurantDetailResultState {
  final String message;

  RestaurantDetailErrorState(this.message);
}
