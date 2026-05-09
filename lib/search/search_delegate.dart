import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/screens/main_shell.dart';
import 'package:peliculas_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar película...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppTheme.textMuted),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppTheme.accentPrimary,
      ),
    );
  }

  // ── Clear query button ─────────────────────────────────────────
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.close_rounded, key: ValueKey('clear')),
          ),
          tooltip: 'Limpiar',
        ),
    ];
  }

  // ── Back button ────────────────────────────────────────────────
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
    );
  }

  // ── Results (when user submits search) ─────────────────────────
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  // ── Suggestions (while typing) ─────────────────────────────────
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState();
    }
    return _buildSearchResults(context);
  }

  // ── Search results list ────────────────────────────────────────
  Widget _buildSearchResults(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: FutureBuilder<List<Movie>>(
        future: moviesProvider.searchMovies(query),
        builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentPrimary,
                strokeWidth: 2.5,
              ),
            );
          }

          final movies = snapshot.data!;

          if (movies.isEmpty) {
            return _buildNoResults();
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: movies.length,
            itemBuilder: (_, int index) {
              final movie = movies[index];
              movie.heroId = 'search-${movie.id}';

              return _MovieSearchTile(
                movie: movie,
                onTap: () {
                  close(context, null);
                  shellNavigatorKey.currentState
                      ?.pushNamed('details', arguments: movie);
                },
              );
            },
          );
        },
      ),
    );
  }

  // ── Empty search state ─────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              size: 80,
              color: AppTheme.accentPrimary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Busca tu película favorita',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escribe el nombre de una película',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── No results state ───────────────────────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 70,
            color: AppTheme.accentWarm.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron resultados',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MOVIE SEARCH TILE — Search result card
// ═══════════════════════════════════════════════════════════════════
class _MovieSearchTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _MovieSearchTile({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: AppTheme.radiusMd,
          border: Border.all(
            color: AppTheme.textMuted.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Poster
            Hero(
              tag: movie.heroId ?? 'search-${movie.id}',
              child: ClipRRect(
                borderRadius: AppTheme.radiusSm,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'),
                  image: NetworkImage(movie.fullPosterImg),
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (movie.year.isNotEmpty)
                    Text(
                      movie.year,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.accentGold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
