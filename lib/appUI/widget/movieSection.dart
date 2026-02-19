import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/widget/moviecard.dart';

class Moviesection extends StatelessWidget {

  final String title;

  const Moviesection({ required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( title,
            style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child:ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index){
                return const Moviecard();
              })
          )
        ],



    );
  }
}
