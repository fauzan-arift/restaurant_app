import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api/api_services.dart';
import 'package:restaurant_app/static/error_message_helper.dart';
import 'package:restaurant_app/static/add_review_state.dart';

class AddReviewProvider extends ChangeNotifier {
  final ApiService _apiService;

  AddReviewProvider(this._apiService);

  AddReviewState _state = AddReviewState.idle;
  String _message = '';
  bool _isBtnEnabled = false;

  AddReviewState get state => _state;
  String get message => _message;
  bool get isBtnEnabled => _isBtnEnabled;
  bool get isLoading => _state == AddReviewState.loading;

  void validateInput(String name, String review) {
    final isValid = name.trim().isNotEmpty && review.trim().isNotEmpty;
    if (_isBtnEnabled != isValid) {
      _isBtnEnabled = isValid;
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required String restaurantId,
    required String name,
    required String review,
  }) async {
    if (!_isBtnEnabled || _state == AddReviewState.loading) return;

    _state = AddReviewState.loading;
    _message = '';
    notifyListeners();

    try {
      await _apiService.addReview(
        id: restaurantId,
        name: name.trim(),
        review: review.trim(),
      );

      _state = AddReviewState.success;
      _message = 'Review berhasil ditambahkan!';
      notifyListeners();
    } catch (e) {
      _state = AddReviewState.error;
      _message = ErrorMessageHelper.getErrorMessage(e.toString());
      notifyListeners();
    }
  }

  void reset() {
    _state = AddReviewState.idle;
    _message = '';
    _isBtnEnabled = false;
    notifyListeners();
  }
}
