import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'What are you looking for?',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSearch,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppTheme.surfaceColor,
      ),
    );
  }
}