import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: searchController,

        onChanged: (value) {
          if (value.isNotEmpty) {
            onSearch(value);
          }
        },

        style: const TextStyle(color: Colors.white),

        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          hintText: "Search movies",
          hintStyle: TextStyle(color: Colors.white60),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}