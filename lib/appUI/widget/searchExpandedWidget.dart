import 'package:flutter/material.dart';

class searchExpandedWidget extends StatelessWidget {
  const searchExpandedWidget({
    super.key,
    required this.movies, required this.isLoading,
  });

  final List movies;
   final bool isLoading ;
  @override

  Widget build(BuildContext context) {
    return Expanded(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          var movie = movies[index];

          String poster =
              "https://image.tmdb.org/t/p/w500${movie['poster_path']}";

          String title = movie["title"] ?? "";
          String year = movie["release_date"] ?? "";

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    poster,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 15),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(
                      width: 200,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      year.isNotEmpty ? year.substring(0, 4) : "",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),

    );
  }
}