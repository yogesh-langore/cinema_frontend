import 'dart:developer';

import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/networking/dio_client.dart';
import 'package:flutter_cinema/repo/movie_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MovieNotifier extends StateNotifier<Map<String, List<Result>>> {
  final MovieRepo movieRepo;

  MovieNotifier(this.movieRepo) : super({});

  Future<void> fetchMovies(String type) async {
    try {
      final movies = await movieRepo.getMoviesByCategory(type);
      state = {
        ...state,
        type: movies,
      };
    } catch (e) {
      log("Failed to fetch movies for type '$type': $e");
      // You can handle this error more gracefully, e.g., by showing a toast message
    }
  }

  Future<void> deleteMovie(String id) async {
    final oldState = Map<String, List<Result>>.from(state);

    state = {
      for (final entry in state.entries)
        entry.key:
            entry.value.where((movie) => movie.id.toString() != id).toList()
    };
    try {
      await movieRepo.ref.read(dioProvider).delete(id);
    } catch (e) {
      log("Failed to delete movie from backend: $e");
      state = oldState;
      rethrow;
    }
  }

  void updateMovieInState(Result updatedMovie) {
    state = {
      for (final entry in state.entries)
        entry.key: entry.value
            .map((movie) => movie.id == updatedMovie.id ? updatedMovie : movie)
            .toList()
    };
  }

  void addMovieToState(Result newMovie, String type) {
    final existing = state[type];
    final existingList = existing is List<Result> ? existing : <Result>[];
    final updatedList = [...existingList, newMovie];
    state = {...state, type: updatedList};
  }
}

final movieProvider =
    StateNotifierProvider<MovieNotifier, Map<String, List<Result>>>((ref) {
  final movieRepo = ref.read(moviesRepoProvider);
  return MovieNotifier(movieRepo);
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'nowPlaying');

final englishMoviesProvider =
    AsyncNotifierProvider<EnglishMoviesNotifier, List<Result>>(
        () => EnglishMoviesNotifier());

class EnglishMoviesNotifier extends AsyncNotifier<List<Result>> {
  @override
  Future<List<Result>> build() async {
    final movieRepo = ref.read(moviesRepoProvider);
    try {
      return await movieRepo.getMoviesByCategory('english');
    } catch (e) {
      log("Error fetching English movies: $e");
      return Future.error(e);
    }
  }
}