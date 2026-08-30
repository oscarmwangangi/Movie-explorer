import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/home/category_results.dart';
import 'package:movie_explorer/appUI/services/tmdb_service.dart';
import 'package:movie_explorer/appUI/widget/hero_banner.dart';
import 'package:movie_explorer/appUI/widget/movieSection.dart';
import 'package:movie_explorer/appUI/shell/app_scaffold.dart';
import 'package:movie_explorer/theme/app_breakpoints.dart';
import 'package:movie_explorer/theme/app_colors.dart';

/// Dedicated TV Shows tab.
///
/// Note: the existing TMDBService only exposes two genuinely TV-backed
/// endpoints (Popular TV, Top Rated TV) — there's no discover/tv genre
/// endpoint like the movie side has for Action/Horror/etc. Rather than
/// add filter chips that would silently return movie results under a
/// TV-shows heading, this screen only offers chips for categories that
/// actually return TV content.
class TVShowsScreen extends StatefulWidget {
  static String id = 'tv_shows_screen';

  const TVShowsScreen({super.key});

  @override
  State<TVShowsScreen> createState() => _TVShowsScreenState();
}

class _TVShowsScreenState extends State<TVShowsScreen> {
  static const List<String> genres = ['TV Series', 'Top Rated TV'];

  dynamic featured;
  List popularTv = [];
  List topRatedTv = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        TMDBService.getTVSeries(),
        TMDBService.getTopRatedTVSeries(),
      ]);
      if (!mounted) return;
      setState(() {
        popularTv = results[0];
        topRatedTv = results[1];
        featured = popularTv.isNotEmpty ? popularTv[0] : null;
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
      activeIndex: 2,
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
                      Text("TV Shows", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: wide ? 32 : 24)),
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
                      Moviesection(title: 'Popular TV Shows', categoryType: 'TV Series', movies: popularTv, isLoading: isLoading),
                      Moviesection(title: 'Top Rated TV', movies: topRatedTv, isLoading: isLoading),
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
