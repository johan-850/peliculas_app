import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CastingCards extends StatelessWidget {
  final int movieId;
  const CastingCards({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder<List<Cast>>(
      future: moviesProvider.getMovieCast(movieId),
      builder: (_, AsyncSnapshot<List<Cast>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 20),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentPrimary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final cast = snapshot.data!;

        if (cast.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Title ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Reparto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                    ),
              ),
            ),

            // ── Cast Horizontal List ──────────────────────────────
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20),
                itemCount: cast.length > 20 ? 20 : cast.length,
                itemBuilder: (_, int index) => _CastCard(actor: cast[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CAST CARD — Individual actor card
// ═══════════════════════════════════════════════════════════════════
class _CastCard extends StatelessWidget {
  final Cast actor;
  const _CastCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          // ── Actor Photo ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: AppTheme.radiusMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppTheme.radiusMd,
              child: FadeInImage(
                placeholder: const AssetImage('assets/no-image.jpg'),
                image: NetworkImage(actor.fullProfileImg),
                width: 110,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Actor Name ─────────────────────────────────────────
          Text(
            actor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          // ── Character Name ─────────────────────────────────────
          if (actor.character != null && actor.character!.isNotEmpty)
            Text(
              actor.character!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
