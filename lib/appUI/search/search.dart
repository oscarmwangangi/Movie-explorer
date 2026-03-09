import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/footer/buildFooter.dart';
import 'package:movie_explorer/appUI/widget/searchExpandedWidget.dart';
import 'package:movie_explorer/appUI/widget/searchBar.dart';
import 'package:movie_explorer/appUI/services/tmdb_service.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static String id = "search.dart";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController searchController = TextEditingController();


  List movies = [];
  bool isLoading = false;


  void onSearch(String query) async {

    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final results = await TMDBService.searchMovies(query);

    setState(() {
      movies = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Stack(
          children: [

            /// Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0f2027),
                    Color(0xff203a43),
                    Color(0xff000000),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
              child: Column(
                children: [

                  /// SEARCH BAR
                  SearchBarWidget(searchController: searchController, onSearch:onSearch),

                  const SizedBox(height: 25),

                  /// MOVIE LIST
                  searchExpandedWidget(movies: movies, isLoading: isLoading,),
                ],
              ),
            ),

            /// FOOTER
            Align(
              alignment: Alignment.bottomCenter,
              child: buildFooter(context),
            ),
          ],
        ),
      ),
    );
  }
}

