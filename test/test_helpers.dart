import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/api/api_services.dart';
import 'package:restaurant_app/data/model/restaurant.dart';
import 'package:restaurant_app/data/model/restaurant_list_response.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockApiService extends Mock implements ApiService {}

class TestDataFactory {
  static Map<String, dynamic> get successRestaurantListJson => {
    "error": false,
    "message": "success",
    "count": 2,
    "restaurants": [
      {
        "id": "rqdv5juczeskfw1e867",
        "name": "Melting Pot",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipisicing elit.",
        "pictureId": "14",
        "city": "Medan",
        "rating": 4.2,
      },
      {
        "id": "s1knt6za9kkfw1e867",
        "name": "Kafe Kita",
        "description": "Quisque rutrum. Aenean imperdiet.",
        "pictureId": "25",
        "city": "Gorontalo",
        "rating": 4.0,
      },
    ],
  };

  static Map<String, dynamic> get errorRestaurantListJson => {
    "error": true,
    "message": "Restaurant not found",
    "count": 0,
    "restaurants": [],
  };

  static RestaurantListResponse get successResponse =>
      RestaurantListResponse.fromJson(successRestaurantListJson);

  static RestaurantListResponse get errorResponse =>
      RestaurantListResponse.fromJson(errorRestaurantListJson);

  static List<Restaurant> get sampleRestaurants => [
    Restaurant(
      id: "rqdv5juczeskfw1e867",
      name: "Melting Pot",
      description: "Lorem ipsum dolor sit amet, consectetur adipisicing elit.",
      pictureId: "14",
      city: "Medan",
      rating: 4.2,
    ),
    Restaurant(
      id: "s1knt6za9kkfw1e867",
      name: "Kafe Kita",
      description: "Quisque rutrum. Aenean imperdiet.",
      pictureId: "25",
      city: "Gorontalo",
      rating: 4.0,
    ),
  ];
}
