import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/detail/add_review_provider.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app/static/add_review_state.dart';

class AddReviewDialog extends StatelessWidget {
  final String restaurantId;

  const AddReviewDialog({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController reviewController = TextEditingController();

    return Consumer<AddReviewProvider>(
      builder: (context, addReviewProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (addReviewProvider.state == AddReviewState.success) {
            context.read<RestaurantDetailProvider>().fetchRestaurantDetail(
              restaurantId,
            );

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(addReviewProvider.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            addReviewProvider.reset();
          } else if (addReviewProvider.state == AddReviewState.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(addReviewProvider.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            addReviewProvider.reset();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rate_review,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tambah Review',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'Masukkan nama Anda',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onChanged: (value) => addReviewProvider.validateInput(
                    nameController.text,
                    reviewController.text,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Review',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'Masukkan review Anda',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.reviews),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onChanged: (value) => addReviewProvider.validateInput(
                    nameController.text,
                    reviewController.text,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: addReviewProvider.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Batalkan'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 45),
                      ),
                      onPressed:
                          addReviewProvider.isBtnEnabled &&
                              !addReviewProvider.isLoading
                          ? () => addReviewProvider.submitReview(
                              restaurantId: restaurantId,
                              name: nameController.text,
                              review: reviewController.text,
                            )
                          : null,
                      child: addReviewProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kirim'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
