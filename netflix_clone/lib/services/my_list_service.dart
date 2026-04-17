import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'dart:convert';

class MyListService {
  static const String _key = 'my_list';

  static Future<List<Movie>> getMyList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Movie.fromJson(json)).toList();
  }

  static Future<void> addToMyList(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getMyList();
    if (!list.any((m) => m.id == movie.id)) {
      list.add(movie);
      final jsonString = json.encode(list.map((m) => m.toJson()).toList());
      prefs.setString(_key, jsonString);
    }
  }

  static Future<void> removeFromMyList(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getMyList();
    list.removeWhere((m) => m.id == movieId);
    final jsonString = json.encode(list.map((m) => m.toJson()).toList());
    prefs.setString(_key, jsonString);
  }

  static Future<bool> isInMyList(int movieId) async {
    final list = await getMyList();
    return list.any((m) => m.id == movieId);
  }
}

