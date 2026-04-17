
import 'package:dio/dio.dart';
import '../api_key.dart';
import '../constants.dart';
import '../models/movie.dart';
import '../models/movie_response.dart';

class TmdbService {
  static final Dio _dio = Dio();
  
  static Future<List<Movie>> getTrending() async {
    try {
      final response = await _dio.get(
        '$tmdbBaseUrl/trending/movie/day?api_key=$tmdbApiKey',
      );
      final data = MovieResponse.fromJson(response.data);
      return data.results;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Movie>> getTopRated() async {
    try {
      final response = await _dio.get(
        '$tmdbBaseUrl/movie/top_rated?api_key=$tmdbApiKey',
      );
      final data = MovieResponse.fromJson(response.data);
      return data.results;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Movie>> getUpcoming() async {
    try {
      final response = await _dio.get(
        '$tmdbBaseUrl/movie/upcoming?api_key=$tmdbApiKey',
      );
      final data = MovieResponse.fromJson(response.data);
      return data.results;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Movie>> getNowPlaying() async {
    try {
      final response = await _dio.get(
        '$tmdbBaseUrl/movie/now_playing?api_key=$tmdbApiKey',
      );
      final data = MovieResponse.fromJson(response.data);
      return data.results;
    } catch (e) {
      return [];
    }
  }

  static Future<String?> getMovieTrailer(int movieId) async {
    try {
      final response = await _dio.get(
        '$tmdbBaseUrl/movie/$movieId/videos?api_key=$tmdbApiKey',
      );
      final List results = response.data['results'];
      final trailer = results.firstWhere(
        (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
        orElse: () => null,
      );
      return trailer?['key'];
    } catch (e) {
      return null;
    }
  }
}

