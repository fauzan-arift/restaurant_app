import 'package:flutter/material.dart';

class ChipListSection extends StatelessWidget {
  final String title;
  final List items;
  final IconData Function(dynamic item)? iconBuilder;
  final Color Function(dynamic item)? colorBuilder;
  final String Function(dynamic item)? labelBuilder;

  const ChipListSection({
    super.key,
    required this.title,
    required this.items,
    this.iconBuilder,
    this.colorBuilder,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final item = items[i];
              final icon = iconBuilder?.call(item) ?? Icons.local_offer;
              final color = colorBuilder?.call(item) ?? Colors.orange;
              final label = labelBuilder?.call(item) ?? item.toString();

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Chip(
                  avatar: Icon(icon, color: color, size: 18),
                  label: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: color.withAlpha((0.2 * 255).toInt()),
                  side: BorderSide(
                    color: color.withAlpha((0.8 * 255).toInt()),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

