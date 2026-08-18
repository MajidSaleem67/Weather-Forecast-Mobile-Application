import 'package:flutter/material.dart';

class RecentSearches extends StatelessWidget {
  final List<String> cities;
  final ValueChanged<String> onCityTap;
  final VoidCallback onClear;

  const RecentSearches({
    super.key,
    required this.cities,
    required this.onCityTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent searches',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = cities[index];
              return ActionChip(
                label: Text(city),
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.white.withOpacity(0.2),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => onCityTap(city),
              );
            },
          ),
        ),
      ],
    );
  }
}
