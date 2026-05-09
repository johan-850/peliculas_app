import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/theme/app_theme.dart';
import 'package:peliculas_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
class DetailScreen extends StatelessWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            _CustomAppBar(movie: movie),
            SliverList(
              delegate: SliverChildListDelegate([
                _PosterAndTitle(movie: movie),
                _RatingBar(movie: movie),
                _TrailerButton(movie: movie),
                _Overview(movie: movie),
                const SizedBox(height: 10),
                CastingCards(movieId: movie.id),
                const SizedBox(height: 10),
                _SimilarMovies(movie: movie),
                const SizedBox(height: 100), // Spacer for bottom navigation bar
              ]),
            ),
            // Fill remaining space so there's no gap at the bottom
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox.shrink(),
            ),
          ],
        ),
      );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM APP BAR — Expandable backdrop image
// ═══════════════════════════════════════════════════════════════════
class _CustomAppBar extends StatelessWidget {
  final Movie movie;
  const _CustomAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.scaffoldBackground,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Text(
            movie.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            FadeInImage(
              placeholder: const AssetImage('assets/loading.gif'),
              image: NetworkImage(movie.fullBackdropPath),
              fit: BoxFit.cover,
            ),
            // Gradient overlay for readability
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Colors.black38,
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// POSTER AND TITLE — Movie info card
// ═══════════════════════════════════════════════════════════════════
class _PosterAndTitle extends StatelessWidget {
  final Movie movie;
  const _PosterAndTitle({required this.movie});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Poster with Hero animation ─────────────────────────
          Hero(
            tag: movie.heroId ?? 'poster-${movie.id}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppTheme.radiusMd,
                boxShadow: AppTheme.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: AppTheme.radiusMd,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'),
                  image: NetworkImage(movie.fullPosterImg),
                  height: 180,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ── Movie Info ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                const SizedBox(height: 6),
                Text(
                  movie.originalTitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                if (movie.year.isNotEmpty)
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: movie.year,
                  ),
                const SizedBox(height: 6),
                _InfoChip(
                  icon: Icons.language_rounded,
                  label: movie.originalLanguage.toUpperCase(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// RATING BAR — Star rating + vote count
// ═══════════════════════════════════════════════════════════════════
class _RatingBar extends StatelessWidget {
  final Movie movie;
  const _RatingBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final rating = movie.voteAverage;
    final fullStars = (rating / 2).floor();
    final halfStar = (rating / 2 - fullStars) >= 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stars
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              if (index < fullStars) {
                return const Icon(Icons.star_rounded,
                    color: AppTheme.accentGold, size: 22);
              } else if (index == fullStars && halfStar) {
                return const Icon(Icons.star_half_rounded,
                    color: AppTheme.accentGold, size: 22);
              }
              return Icon(Icons.star_outline_rounded,
                  color: AppTheme.accentGold.withValues(alpha: 0.3), size: 22);
            }),
          ),
          const SizedBox(width: 10),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${movie.voteCount} votos)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// OVERVIEW — Movie synopsis
// ═══════════════════════════════════════════════════════════════════
class _Overview extends StatelessWidget {
  final Movie movie;
  const _Overview({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sinopsis',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview.isNotEmpty
                ? movie.overview
                : 'No hay sinopsis disponible para esta película.',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// INFO CHIP — Small info tag
// ═══════════════════════════════════════════════════════════════════
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: AppTheme.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TRAILER BUTTON
// ═══════════════════════════════════════════════════════════════════
class _TrailerButton extends StatelessWidget {
  final Movie movie;
  const _TrailerButton({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        icon: const Icon(Icons.play_circle_fill_rounded, size: 24),
        label: const Text(
          'Ver Tráiler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final provider = Provider.of<MoviesProvider>(context, listen: false);
          final url = await provider.getMovieTrailer(movie.id);
          
          if (url != null) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo abrir el tráiler.')),
                );
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tráiler no disponible.')),
              );
            }
          }
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SIMILAR MOVIES
// ═══════════════════════════════════════════════════════════════════
class _SimilarMovies extends StatelessWidget {
  final Movie movie;
  const _SimilarMovies({required this.movie});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder(
      future: provider.getSimilarMovies(movie),
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Text('Error al cargar similares: ${snapshot.error}', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.accentPrimary),
            ),
          );
        }

        final movies = snapshot.data!;
        if (movies.isEmpty) return const SizedBox.shrink();

        return MovieSlider(
          movies: movies,
          title: 'Películas Similares',
          onNextPage: () {}, // Sin paginación para similares
        );
      },
    );
  }
}