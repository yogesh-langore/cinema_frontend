import 'dart:developer';

import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/networking/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MovieRepo {
  final Ref ref;

  MovieRepo(this.ref);

  Future<List<Result>> getMoviesByCategory(String category) async {
    try {
      final response = await ref.read(dioProvider).get(category);
      if (response.statusCode == 200) {
        var decodedJson = response.data;
        final List<Result> movies =
            decodedJson.map<Result>((data) => Result.fromJson(data)).toList();
        return movies;
      } else {
        throw Exception('Failed to load data for category: $category');
      }
    } catch (e) {
      log("Error in MovieRepo for category '$category': $e");
      rethrow;
    }
  }

  Future<List<Result>> searchMovies(String query) async {
    try {
      final response = await ref.read(dioProvider).searchMovies(query);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => Result.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to search movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log("Error in MovieRepo searchMovies: $e");
      rethrow;
    }
  }
}

final moviesRepoProvider = Provider((ref) => MovieRepo(ref));