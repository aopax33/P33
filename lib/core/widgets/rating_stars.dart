import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showLabel;
  final int? totalRatings;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.showLabel = false,
    this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          final isFull = rating >= starValue;
          final isHalf = !isFull && rating >= starValue - 0.5;

          IconData icon;
          if (isFull) {
            icon = Icons.star;
          } else if (isHalf) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return Icon(
            icon,
            color: isFull || isHalf ? AppTheme.starColor : AppTheme.starEmptyColor,
            size: size,
          );
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (totalRatings != null) ...[
            const SizedBox(width: 4),
            Text(
              '($totalRatings)',
              style: TextStyle(
                fontSize: size * 0.65,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class InteractiveRatingStars extends StatefulWidget {
  final double initialRating;
  final int maxRating;
  final double size;
  final ValueChanged<double> onRatingChanged;

  const InteractiveRatingStars({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 40,
    required this.onRatingChanged,
  });

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starValue = (index + 1).toDouble();
        final isFilled = _currentRating >= starValue;

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue;
            });
            widget.onRatingChanged(starValue);
          },
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? AppTheme.starColor : AppTheme.starEmptyColor,
            size: widget.size,
          ),
        );
      }),
    );
  }
}
