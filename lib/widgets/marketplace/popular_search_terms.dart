import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PopularSearchTerms extends StatelessWidget {
  final List<String> terms;
  final Function(String) onTermSelected;

  const PopularSearchTerms({
    Key? key,
    required this.terms,
    required this.onTermSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: terms.map((term) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(term),
              onPressed: () => onTermSelected(term),
              backgroundColor: AppTheme.surfaceColor,
            ),
          );
        }).toList(),
      ),
    );
  }
}