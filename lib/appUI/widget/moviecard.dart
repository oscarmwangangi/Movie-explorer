import 'package:flutter/material.dart';

class Moviecard extends StatelessWidget {
  const Moviecard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://image.tmdb.org/t/p/w500/9SSEUrSqhljBMzRe4aBTh17rUaC.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}