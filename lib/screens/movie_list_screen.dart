import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/screens/main_shell.dart';
import 'package:peliculas_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatefulWidget {
  final String title;
  const MovieListScreen({super.key, required this.title});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      if (!_isLoading) {
        _isLoading = true;
        final provider = Provider.of<MoviesProvider>(context, listen: false);
        provider.getPopularMovies().then((_) {
          Future.delayed(const Duration(seconds: 1), () {
            _isLoading = false;
          });
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
    final moviesProvider = Provider.of<MoviesProvider>(context);
    final movies = moviesProvider.popularMovies;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground.withValues(alpha: 0.85),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 30),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.52,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length + 1,
          itemBuilder: (context, index) {
            // Loading indicator at the end
            if (index == movies.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: AppTheme.accentPrimary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final movie = movies[index];
            movie.heroId = 'grid-${movie.id}-$index';

            return _MovieGridCard(movie: movie);
          },
        ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MOVIE GRID CARD
// ═══════════════════════════════════════════════════════════════════
class _MovieGridCard extends StatelessWidget {
  final Movie movie;
  const _MovieGridCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => shellNavigatorKey.currentState?.pushNamed('details', arguments: movie),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: Hero(
              tag: movie.heroId ?? 'grid-${movie.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppTheme.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppTheme.radiusMd,
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/no-image.jpg'),
                    image: NetworkImage(movie.fullPosterImg),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Title
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
          const SizedBox(height: 2),

          // Rating + Year
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppTheme.accentGold, size: 12),
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
