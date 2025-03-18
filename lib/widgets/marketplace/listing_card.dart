import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String timePosted;
  final String imageUrl;
  final bool isSold;
  final VoidCallback onTap;

  const ListingCard({
    Key? key,
    required this.title,
    required this.price,
    required this.location,
    required this.timePosted,
    required this.imageUrl,
    this.isSold = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with sold overlay if needed
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.surfaceColor,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isSold)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Text(
                          'SOLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        timePosted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}