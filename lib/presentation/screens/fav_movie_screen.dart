// ✅ FULL WORKING FavScreen with Snackbar Fix
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cinema/presentation/screens/movies_details_screen.dart';
import 'package:flutter_cinema/providers/fav_movie_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavScreen extends ConsumerWidget {
  const FavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favMovies = ref.watch(favMoviesProvider);
    final notifier = ref.read(favMoviesProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1116),
      appBar: AppBar(
        title: const Text('Favorite Movies',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favMovies.isEmpty
          ? const Center(
              child: Text(
                'Your favorite movies list is empty.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favMovies.length,
              itemBuilder: (context, index) {
                final movie = favMovies[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsScreen(result: movie),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (movie.posterPath != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w200/${movie.posterPath}',
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 80,
                                      height: 120,
                                      color: Colors.grey[900],
                                      child: const Icon(Icons.movie,
                                          color: Colors.white54, size: 40),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 80,
                                  height: 120,
                                  color: Colors.grey[900],
                                  child: const Icon(Icons.movie,
                                      color: Colors.white54, size: 40),
                                ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.originalTitle ??
                                          movie.title ??
                                          'Unknown Title',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      movie.overview ??
                                          'No overview available.',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Release Year: ${movie.releaseDate?.toString() ?? '---'}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 4,
                          child: Builder(
                              // Re-adding Builder here for an explicit, local context
                              builder: (localContext) {
                            return IconButton(
                              icon: const Icon(Icons.bookmark_remove_sharp,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                final confirm =
                                    await showModalBottomSheet<bool>(
                                  context: localContext,
                                  backgroundColor: const Color(0xFF121212),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ... (modal sheet content)
                                          Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[700],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Icon(
                                              Icons.delete_forever_rounded,
                                              size: 50,
                                              color: Colors.redAccent),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Remove from Favorites?",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text("Cancel",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white70)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: const Text("Remove"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  // Await the state change first
                                  await notifier
                                      .removeFavorite(movie.id.toString());
                                  // Then show the snackbar using the localContext
                                  ScaffoldMessenger.of(localContext)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(localContext)
                                      .showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF2C2C2E),
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      content: const Row(
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.white70),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Movie removed from favorites.',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        textColor: Colors.yellowAccent,
                                        onPressed: () async {
                                          await notifier.addFavorite(movie);
                                        },
                                      ),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                  log('Snackbar show call finished.');
                                }
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
