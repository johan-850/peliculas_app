import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/screens/main_shell.dart';
import 'package:peliculas_app/theme/app_theme.dart';

class MovieSlider extends StatefulWidget {
  final List<Movie> movies;
  final String title;
  final Function? onNextPage;

  const MovieSlider({
    super.key,
    required this.movies,
    required this.title,
    this.onNextPage,
  });

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading) {
        _isLoading = true;
        widget.onNextPage?.call();
        // Reset loading flag after a delay
        Future.delayed(const Duration(seconds: 1), () {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 310,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Title ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => shellNavigatorKey.currentState?.pushNamed(
                    'movie_list',
                    arguments: {'title': widget.title},
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.1),
                      borderRadius: AppTheme.radiusSm,
                    ),
                    child: const Text(
                      'Ver todo',
                      style: TextStyle(
                        color: AppTheme.accentPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Horizontal List ────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20),
              itemCount: widget.movies.length,
              itemBuilder: (_, int index) {
                final movie = widget.movies[index];
                return _MoviePoster(movie: movie, index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MOVIE POSTER — Individual movie card in the horizontal slider
// ═══════════════════════════════════════════════════════════════════
class _MoviePoster extends StatelessWidget {
  final Movie movie;
  final int index;
  const _MoviePoster({required this.movie, required this.index});

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'slider-${movie.id}-$index';

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Poster Image ───────────────────────────────────────
          GestureDetector(
            onTap: () => shellNavigatorKey.currentState?.pushNamed(
              'details',
              arguments: movie,
            ),
            child: Hero(
              tag: movie.heroId!,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppTheme.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppTheme.radiusMd,
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/no-image.jpg'),
                    image: NetworkImage(movie.fullPosterImg),
                    width: 130,
                    height: 195,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Title ──────────────────────────────────────────────
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),

          // ── Rating ─────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppTheme.accentGold, size: 13),
              const SizedBox(width: 3),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (movie.year.isNotEmpty) ...[
                const Spacer(),
                Text(
                  movie.year,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}