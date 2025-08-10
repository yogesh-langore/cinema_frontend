import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/repo/hive_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final hiveRepoProvider = Provider<HiveRepo>((ref) => HiveRepo());

class FavMoviesNotifier extends StateNotifier<List<Result>> {
  final HiveRepo hiveRepo;

  FavMoviesNotifier(this.hiveRepo) : super([]) {
    loadFavMovies();
  }

  Future<void> loadFavMovies() async {
    final movies = await hiveRepo.getAllFavMoviesFromHive();
    state = movies;
  }

  Future<void> addFavorite(Result movie) async {
    if (state.any((m) => m.id == movie.id)) return;
    state = [...state, movie];
    await hiveRepo.addMovieToHive(movie);
  }

  Future<void> removeFavorite(String id) async {
    state = state.where((m) => m.id != id).toList();
    await hiveRepo.deleteMovieFromHive(id);
  }
}

final favMoviesProvider =
    StateNotifierProvider<FavMoviesNotifier, List<Result>>((ref) {
  final hiveRepo = ref.watch(hiveRepoProvider);
  return FavMoviesNotifier(hiveRepo);
});
