import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = 'f7baea359ce18783053eda3ea74bc4cf';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  // Cache for movie cast
  final Map<int, List<Cast>> _moviesCast = {};

  // Pagination
  int _popularPage = 0;

  // Search
  Timer? _debounceTimer;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  // ── Generic JSON fetcher ───────────────────────────────────────
  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });
    final response = await http.get(url);
    return response.body;
  }

  // ── Now Playing ────────────────────────────────────────────────
  Future<void> getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  // ── Popular (with infinite scroll) ─────────────────────────────
  Future<void> getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  // ── Movie Cast (with cache) ────────────────────────────────────
  Future<List<Cast>> getMovieCast(int movieId) async {
    // Return cached if available
    if (_moviesCast.containsKey(movieId)) {
      return _moviesCast[movieId]!;
    }

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    _moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  // ── Search (with debounce) ─────────────────────────────────────
  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  /// Debounced search that streams results
  void getSuggestionsByQuery(String query, Function(List<Movie>) callback) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty) {
        callback([]);
        return;
      }
      final results = await searchMovies(query);
      callback(results);
    });
  }

  // ── Genres ─────────────────────────────────────────────────────
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> get genres => _genres;

  // Cache for movies by genre
  final Map<int, List<Movie>> _moviesByGenre = {};

  Future<void> getGenres() async {
    if (_genres.isNotEmpty) return;

    final url = Uri.https(_baseUrl, '3/genre/movie/list', {
      'api_key': _apiKey,
      'language': _language,
    });
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    _genres = List<Map<String, dynamic>>.from(data['genres']);
    notifyListeners();
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    if (page == 1 && _moviesByGenre.containsKey(genreId)) {
      return _moviesByGenre[genreId]!;
    }

    final url = Uri.https(_baseUrl, '3/discover/movie', {
      'api_key': _apiKey,
      'language': _language,
      'with_genres': '$genreId',
      'sort_by': 'popularity.desc',
      'page': '$page',
    });
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final movies = List<Movie>.from(
      (data['results'] as List).map((m) => Movie.fromMap(m)),
    );

    if (page == 1) {
      _moviesByGenre[genreId] = movies;
    } else {
      if (_moviesByGenre.containsKey(genreId)) {
        _moviesByGenre[genreId]!.addAll(movies);
      } else {
        _moviesByGenre[genreId] = movies;
      }
    }
    
    return _moviesByGenre[genreId]!;
  }

  // ── Trailer ────────────────────────────────────────────────────
  Future<String?> getMovieTrailer(int movieId) async {
    var url = Uri.https(_baseUrl, '3/movie/$movieId/videos', {
      'api_key': _apiKey,
      'language': _language,
    });
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    var results = data['results'] as List;

    if (results.isEmpty) {
      url = Uri.https(_baseUrl, '3/movie/$movieId/videos', {
        'api_key': _apiKey,
        'language': 'en-US',
      });
      response = await http.get(url);
      data = jsonDecode(response.body);
      results = data['results'] as List;
    }

    if (results.isEmpty) return null;

    final trailer = results.firstWhere(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
      orElse: () {
        final anyYoutube = results.where((v) => v['site'] == 'YouTube');
        return anyYoutube.isNotEmpty ? anyYoutube.first : null;
      },
    );

    if (trailer != null && trailer['key'] != null) {
      return 'https://www.youtube.com/watch?v=${trailer['key']}';
    }
    return null;
  }

  // ── Similar Movies ─────────────────────────────────────────────
  Future<List<Movie>> getSimilarMovies(Movie movie) async {
    if (movie.genreIds.isEmpty) {
      final jsonData = await _getJsonData('3/movie/${movie.id}/similar');
      final popularResponse = PopularResponse.fromJson(jsonData);
      return popularResponse.results;
    }

    // Use discover to find movies with similar genres, sorted by popularity
    final genres = movie.genreIds.take(2).join(','); // Use up to 2 genres
    final url = Uri.https(_baseUrl, '3/discover/movie', {
      'api_key': _apiKey,
      'language': _language,
      'with_genres': genres,
      'sort_by': 'popularity.desc',
      'page': '1',
    });

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final results = List<Movie>.from(
      (data['results'] as List).map((m) => Movie.fromMap(m)),
    );

    // Remove the current movie if it appears in the results
    results.removeWhere((m) => m.id == movie.id);

    return results;
  }
}
