import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/networking/dio_client.dart';
import 'package:flutter_cinema/providers/fav_movie_providers.dart';
import 'package:flutter_cinema/providers/movie_providers.dart';
import 'package:flutter_cinema/utils/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  const MovieDetailsScreen({super.key, required this.result});
  final Result result;

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  bool isEditing = false;
  late Result movie;

  late TextEditingController originaltitleController;
  late TextEditingController overviewController;
  late TextEditingController imdbController;
  late TextEditingController releaseDateController;
  late TextEditingController genresController;
  late TextEditingController runtimeController;
  late TextEditingController languageController;
  late TextEditingController seasonsController;
  late TextEditingController episodesController;

  @override
  void initState() {
    super.initState();
    movie = widget.result;
    originaltitleController = TextEditingController(text: movie.originalTitle);
    overviewController = TextEditingController(text: movie.overview);
    imdbController = TextEditingController(text: movie.imdb?.toString());
    releaseDateController = TextEditingController(
      text: movie.releaseDate?.toString() ?? '',
    );
    genresController =
        TextEditingController(text: movie.genres?.join(', ') ?? '');
    runtimeController = TextEditingController(text: movie.runTime ?? '');
    languageController = TextEditingController(text: movie.originalLanguage);
    seasonsController = TextEditingController(text: movie.seasons?.toString());
    episodesController =
        TextEditingController(text: movie.episodes?.toString());
  }

  @override
  void dispose() {
    originaltitleController.dispose();
    overviewController.dispose();
    imdbController.dispose();
    releaseDateController.dispose();
    genresController.dispose();
    runtimeController.dispose();
    languageController.dispose();
    seasonsController.dispose();
    episodesController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final updatedMovie = movie.copyWith(
      originalTitle: originaltitleController.text,
      overview: overviewController.text,
      imdb: double.tryParse(imdbController.text),
      releaseDate: int.tryParse(releaseDateController.text),
      genres: genresController.text.split(',').map((e) => e.trim()).toList(),
      runTime: runtimeController.text,
      originalLanguage: languageController.text,
      seasons: int.tryParse(seasonsController.text),
      episodes: int.tryParse(episodesController.text),
    );

    try {
      await ref.read(dioProvider).updateMovie(movie.id.toString(), {
        "original_title": updatedMovie.originalTitle,
        "overview": updatedMovie.overview,
        "IMDB": updatedMovie.imdb ?? 0.0,
        "release_date": updatedMovie.releaseDate,
        "genres": updatedMovie.genres,
        "runTime": updatedMovie.runTime,
        "original_language": updatedMovie.originalLanguage,
        "seasons": updatedMovie.seasons,
        "episodes": updatedMovie.episodes,
      });

      ref.read(movieProvider.notifier).updateMovieInState(updatedMovie);
      setState(() {
        isEditing = false;
        movie = updatedMovie;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Movie updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  bool get isTvSeries =>
      movie.foundIn.contains('hindi') || movie.foundIn.contains('english');

  @override
  Widget build(BuildContext context) {
    final genres = movie.genres ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.save : Icons.edit,
              color: Colors.blue.shade800,
            ),
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: const Color(0xFF1E1E1E),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          "Delete Movie?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Are you sure want to delete this movie from your database?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[400],
                              ),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
              log('>>> MovieDetailsScreen: Dialog confirmed: $confirm');
              if (confirm == true) {
                try {
                  log('>>> MovieDetailsScreen: Confirmed. Attempting to delete movie from provider...');
                  await ref
                      .read(movieProvider.notifier)
                      .deleteMovie(movie.id.toString());
                  log('>>> MovieDetailsScreen: MovieNotifier.deleteMovie successful. Popping with movie: ${movie.title}');
                  Navigator.pop(context, movie);
                } catch (e) {
                  log('>>> MovieDetailsScreen: Error during movie deletion: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete movie: $e")),
                  );
                  Navigator.pop(context);
                }
              } else {
                log('>>> MovieDetailsScreen: Delete cancelled. Popping without returning movie.');
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: '$imageUrl${movie.backdropPath ?? ''}',
                height: 400,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 24,
            child: isEditing
                ? Container()
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "IMDb ${movie.imdb?.toStringAsFixed(1) ?? '-'}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 340,
            right: 24,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {
                    ref.read(favMoviesProvider.notifier).addFavorite(movie);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF2C2C2E),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.greenAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${movie.originalTitle} added to favorites!',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.45,
              maxChildSize: 0.9,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ListView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: imdbController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: "IMDb Rating",
                              hintText: "e.g., 8.5",
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      isEditing
                          ? TextField(
                              controller: originaltitleController,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Movie Title",
                                hintStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            )
                          : Text(
                              movie.originalTitle ?? '',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                      const SizedBox(height: 6),
                      isEditing
                          ? TextField(
                              controller: genresController,
                              decoration: const InputDecoration(
                                labelText: "Genres (comma-separated)",
                                hintText: "e.g., Action, Comedy, Sci-Fi",
                                labelStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: [
                                ...genres.map((genre) => Chip(
                                      label: Text(
                                        genre,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 13),
                                      ),
                                      backgroundColor: Colors.yellow[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                            color: Colors.black),
                                      ),
                                    )),
                              ],
                            ),
                      const SizedBox(height: 16),
                      isEditing
                          ? Column(
                              children: [
                                TextField(
                                  controller: releaseDateController,
                                  decoration: const InputDecoration(
                                    labelText: "Release Year",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                TextField(
                                  controller: runtimeController,
                                  decoration: const InputDecoration(
                                    labelText: "Runtime (e.g. 2h 10m)",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                if (isTvSeries) ...[
                                  TextField(
                                    controller: seasonsController,
                                    decoration: const InputDecoration(
                                      labelText: "Total Seasons",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  TextField(
                                    controller: episodesController,
                                    decoration: const InputDecoration(
                                      labelText: "Total Episodes",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                                TextField(
                                  controller: languageController,
                                  decoration: const InputDecoration(
                                    labelText: "Language",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            )
                          : IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: Colors.grey[400], size: 20),
                                        const SizedBox(height: 6),
                                        Text(
                                          movie.releaseDate?.toString() ??
                                              '---',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    color: Colors.grey[700],
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: Colors.grey[400], size: 20),
                                        const SizedBox(height: 6),
                                        if (isTvSeries)
                                          Text(
                                            '${movie.episodes ?? '---'} Episodes',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        else
                                          Text(
                                            movie.runTime ?? '---',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    color: Colors.grey[700],
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(Icons.language,
                                            color: Colors.grey[400], size: 20),
                                        const SizedBox(height: 6),
                                        Text(
                                          movie.originalLanguage
                                                  ?.toUpperCase() ??
                                              '---',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      if (isTvSeries)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.live_tv_rounded,
                                  color: Colors.grey[400], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${movie.seasons ?? '---'} Seasons',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 22),
                      Text(
                        "Overview",
                        style: TextStyle(
                            color: Colors.blueAccent.shade100, fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      isEditing
                          ? TextField(
                              controller: overviewController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: "Overview",
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            )
                          : Text(
                              movie.overview ?? '',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                      // New Cast Section
                      const SizedBox(height: 24),
                      if (movie.cast != null && movie.cast!.isNotEmpty) ...[
                        Text(
                          'Cast',
                          style: TextStyle(
                              color: Colors.blueAccent.shade100, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height:
                              250, // Set a fixed height for the horizontal list
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movie.cast!.length,
                            itemBuilder: (context, index) {
                              final castMember = movie.cast![index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text('Profile coming soon'),
                                                duration:
                                                    Duration(seconds: 2)));
                                      },
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '$imageUrl${castMember['profile_path']}',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.fill,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.person,
                                                  size: 80),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Actor Name
                                    Text(
                                      castMember['actor_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    // Character Name
                                    Text(
                                        castMember['character_name'] ??
                                            'Unknown',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
