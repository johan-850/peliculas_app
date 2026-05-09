import 'package:flutter/material.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/screens/screens.dart';
import 'package:peliculas_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Global navigator key for the nested navigator inside the shell.
/// All screens push/pop using this key so the bottom navbar stays visible.
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home with nested navigator
            _NestedNavigator(),
            // Tab 1: Explore (containing Categories)
            _CategoriesNavigator(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.accentPrimary.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isActive: _currentIndex == 0,
                onTap: () {
                  if (_currentIndex == 0) {
                    // Pop to root if already on Home tab
                    shellNavigatorKey.currentState
                        ?.popUntil((route) => route.isFirst);
                  }
                  setState(() => _currentIndex = 0);
                },
              ),
              _NavBarItem(
                icon: Icons.explore_rounded,
                label: 'Explorar',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NESTED NAVIGATOR FOR HOME
// ═══════════════════════════════════════════════════════════════════
class _NestedNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: shellNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        Widget page;

        switch (settings.name) {
          case 'details':
            final movie = settings.arguments as Movie;
            page = DetailScreen(movie: movie);
            break;
          case 'movie_list':
            final args = settings.arguments as Map<String, dynamic>?;
            page = MovieListScreen(title: args?['title'] ?? 'Películas');
            break;
          case '/':
          default:
            page = const HomeScreen();
        }

        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NESTED NAVIGATOR FOR CATEGORIES
// ═══════════════════════════════════════════════════════════════════
class _CategoriesNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        Widget page;

        switch (settings.name) {
          case 'details':
            final movie = settings.arguments as Movie;
            page = DetailScreen(movie: movie);
            break;
          case '/':
          default:
            page = const _CategoriesTab();
        }

        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NAV BAR ITEM
// ═══════════════════════════════════════════════════════════════════
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentPrimary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppTheme.accentPrimary : AppTheme.textMuted,
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isActive ? AppTheme.accentPrimary : AppTheme.textMuted,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(top: 3),
              height: 3,
              width: isActive ? 16 : 0,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EXPLORE TAB
// ═══════════════════════════════════════════════════════════════════
class _ExploreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_rounded,
              size: 70,
              color: AppTheme.accentPrimary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Explora películas',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Próximamente: categorías y recomendaciones',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CATEGORIES TAB
// ═══════════════════════════════════════════════════════════════════
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab({super.key});

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  int? _selectedGenreId;
  List<Movie> _genreMovies = [];
  bool _loadingMovies = false;
  
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isFetchingMore = false;

  // Genre icon mapping
  static final Map<int, IconData> _genreIcons = {
    28: Icons.local_fire_department_rounded,
    12: Icons.explore_rounded,
    16: Icons.animation,
    35: Icons.sentiment_very_satisfied_rounded,
    80: Icons.policy_rounded,
    99: Icons.videocam_rounded,
    18: Icons.theater_comedy_rounded,
    10751: Icons.family_restroom_rounded,
    14: Icons.auto_awesome_rounded,
    36: Icons.menu_book_rounded,
    27: Icons.psychology_rounded,
    10402: Icons.music_note_rounded,
    9648: Icons.search_rounded,
    10749: Icons.favorite_rounded,
    878: Icons.rocket_launch_rounded,
    10770: Icons.tv_rounded,
    53: Icons.bolt_rounded,
    10752: Icons.shield_rounded,
    37: Icons.landscape_rounded,
  };

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MoviesProvider>(context, listen: false);
    provider.getGenres();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      _loadMoreMovies();
    }
  }

  void _loadMoreMovies() async {
    if (_isFetchingMore || _selectedGenreId == null || _loadingMovies) return;

    _isFetchingMore = true;
    _currentPage++;
    
    final provider = Provider.of<MoviesProvider>(context, listen: false);
    final moreMovies = await provider.getMoviesByGenre(_selectedGenreId!, page: _currentPage);
    
    setState(() {
      _genreMovies = moreMovies;
      _isFetchingMore = false;
    });
  }

  void _selectGenre(int genreId) async {
    if (_selectedGenreId == genreId) return;

    setState(() {
      _selectedGenreId = genreId;
      _loadingMovies = true;
      _currentPage = 1;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    final provider = Provider.of<MoviesProvider>(context, listen: false);
    final movies = await provider.getMoviesByGenre(genreId, page: _currentPage);

    setState(() {
      _genreMovies = movies;
      _loadingMovies = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoviesProvider>(context);
    final genres = provider.genres;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Categorías',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Genre chips
          if (genres.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: AppTheme.accentPrimary,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  final id = genre['id'] as int;
                  final name = genre['name'] as String;
                  final isSelected = _selectedGenreId == id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _selectGenre(id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected ? AppTheme.accentGradient : null,
                          color: isSelected
                              ? null
                              : AppTheme.surfaceCard.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppTheme.textMuted
                                      .withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _genreIcons[id] ?? Icons.movie_rounded,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Content area
          Expanded(
            child: _selectedGenreId == null
                ? _buildEmptyState()
                : _loadingMovies
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : _buildMovieGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_rounded,
            size: 60,
            color: AppTheme.accentPrimary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 14),
          const Text(
            'Selecciona una categoría',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Descubre películas por género',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid() {
    return GridView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: _genreMovies.length,
      itemBuilder: (context, index) {
        final movie = _genreMovies[index];
        movie.heroId = 'cat-${movie.id}-$index';

        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('details', arguments: movie),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: movie.heroId!,
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
              const SizedBox(height: 5),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.accentGold, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
