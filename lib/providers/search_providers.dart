import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/repo/movie_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryProvider = StateProvider<String>((ref) => '');
final movieSearchProvider =
    FutureProvider.family<List<Result>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  return await ref.watch(moviesRepoProvider).searchMovies(query);
});