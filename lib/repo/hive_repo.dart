import 'dart:developer';

import 'package:flutter_cinema/models/cinema.dart';
import 'package:hive/hive.dart';

class HiveRepo {
  final movieboxname = 'moviebox';
  void registerAdapter() {
    Hive.registerAdapter(ResultAdapter());
  }

  Future addMovieToHive(Result movie) async {
  final moviebox = await Hive.openBox<Result>(movieboxname);
  if (movie.id != null) {
    await moviebox.put(movie.id, movie);
    log('Movie added to Hive ${movie.title}');
  } else {
    log('Cannot add to Hive: Movie ID is null');
  }
}


  Future<List<Result>> getAllFavMoviesFromHive() async {
    final moviebox = await Hive.openBox<Result>(movieboxname);
    if (moviebox.isOpen) {
      return moviebox.values.toList();
    } else {
      return [];
    }
  }

  Future deleteMovieFromHive(String id) async {
    final moviebox = await Hive.openBox<Result>(movieboxname);
    await moviebox.delete(id);
  }
}
