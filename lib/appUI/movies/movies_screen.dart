import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/home/category_results.dart';
import 'package:movie_explorer/appUI/services/tmdb_service.dart';
import 'package:movie_explorer/appUI/widget/hero_banner.dart';
import 'package:movie_explorer/appUI/widget/movieSection.dart';
import 'package:movie_explorer/appUI/shell/app_scaffold.dart';
import 'package:movie_explorer/theme/app_breakpoints.dart';
import 'package:movie_explorer/theme/app_colors.dart';

/// Dedicated Movies tab: a featured title, genre filter chips that open
/// the full paginated grid for that genre, and the movie-only rails
/// already fetched elsewhere in the app (no duplicate API calls beyond
/// what Home already needs).
class MoviesScreen extends StatefulWidget {
  static String id = 'movies_screen';

  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  static const List<String> genres = [
    'Popular Movies',
    'Top Rated Movies',
    'Now Playing',
    'Upcoming',
    'Action',
    'Sci-Fi & Fantasy',
    'Horror',
    'Romance',
    'Documentaries',
    'Kids & Animation',
  ];

  dynamic featured;
  List popular = [];
  List topRated = [];
  List nowPlaying = [];
  List upcoming = [];
  List action = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        TMDBService.getPopularMovies(),
        TMDBService.getTopRatedMovies(),
        TMDBService.getNowPlayingMovies(),
        TMDBService.getUpcomingMovies(),
        TMDBService.getActionMovies(),
      ]);
      if (!mounted) return;
      setState(() {
        popular = results[0];
        topRated = results[1];
        nowPlaying = results[2];
        upcoming = results[3];
        action = results[4];
        featured = popular.isNotEmpty ? popular[0] : null;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _openGenre(String genre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryResultsScreen(title: genre, items: const []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = AppBreakpoints.isDesktopOrTV(context);

    return AppScaffold(
      activeIndex: 1,
      constrainBody: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              Container(
                height: AppBreakpoints.heroHeight(context) * 0.7,
                color: AppColors.surface,
                child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              )
            else if (featured != null)
              HeroBanner(movie: featured),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text("Movies", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: wide ? 32 : 24)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) => ChoiceChip(
                            label: Text(genres[index]),
                            selected: false,
                            onSelected: (_) => _openGenre(genres[index]),
                            backgroundColor: AppColors.surface,
                            labelStyle: const TextStyle(color: Colors.white),
                            side: const BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Moviesection(title: 'Popular Movies', movies: popular, isLoading: isLoading),
                      Moviesection(title: 'Top Rated Movies', movies: topRated, isLoading: isLoading),
                      Moviesection(title: 'Now Playing', movies: nowPlaying, isLoading: isLoading),
                      Moviesection(title: 'Upcoming', movies: upcoming, isLoading: isLoading),
                      Moviesection(title: 'Action', movies: action, isLoading: isLoading),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
