import 'package:flutter/material.dart';

class DescriptionSection extends StatelessWidget {
  final String description;
  const DescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.justify,
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
