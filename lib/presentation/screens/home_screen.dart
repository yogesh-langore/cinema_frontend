import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/networking/dio_client.dart';
import 'package:flutter_cinema/presentation/screens/movies_details_screen.dart';
import 'package:flutter_cinema/providers/movie_providers.dart';
import 'package:flutter_cinema/utils/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(movieProvider.notifier);
      final types = [
        "nowPlaying",
        "popular",
        "topRated",
        "upComing",
        "hindi",
        "english"
      ]; 
      for (final type in types) {
        await Future.delayed(const Duration(milliseconds: 300));
        await notifier.fetchMovies(type);
      }
    });
  }

  // Helper method for navigation and handling deletion result
  Future<void> _navigateToMovieDetails(
      BuildContext context, WidgetRef ref, Result movie) async {
    log('>>> HomeScreen: Entering _navigateToMovieDetails for movie: ${movie.originalTitle}');

    final deletedMovie = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(result: movie),
      ),
    );
    log('>>> HomeScreen: Returned from MovieDetailsScreen. Value: $deletedMovie, Type: ${deletedMovie.runtimeType}');

    if (deletedMovie is Result) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${deletedMovie.originalTitle ?? deletedMovie.title} deleted from database.'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.yellow,
            onPressed: () async {
              try {
                final reAddedMovie = await ref
                    .read(dioProvider)
                    .createMovie(deletedMovie.toJson());

                for (final category in deletedMovie.foundIn) {
                  ref
                      .read(movieProvider.notifier)
                      .addMovieToState(reAddedMovie, category);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Movie restored successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to restore movie: $e')),
                );
              }
            },
          ),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 150, left: 15, right: 15),
        ),
      );
    } else {
      log('>>> HomeScreen: deletedMovie is Not a Result, or is Null. SnackBar will NOT be shown.');
      if (deletedMovie == null) {
        log('>>> HomeScreen: deletedMovie is explicitly null.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMovies = ref.watch(movieProvider);
    final selectedType = ref.watch(selectedCategoryProvider);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Use .when() to handle the AsyncValue states
    final englishMoviesAsync = ref.watch(englishMoviesProvider);

    // This list will be used for the GridView, but not for the carousel.
    final moviesList = allMovies[selectedType] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              englishMoviesAsync.when(
                data: (englishMovies) {
                  if (englishMovies.isEmpty) {
                    return SizedBox(
                      height: height * 0.70,
                      child: const Center(
                        child: Text(
                          'No English movies available.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return CarouselSlider.builder(
                    itemCount: englishMovies.length,
                    itemBuilder: (context, index, realIndex) {
                      final movie = englishMovies[index];
                      return GestureDetector(
                        onTap: () =>
                            _navigateToMovieDetails(context, ref, movie),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: '$imageUrl${movie.posterPath}',
                                  fit: BoxFit.fill,
                                  width: width,
                                  height: height * 0.70,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.blueAccent),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    debugPrint(
                                        "Image load failed for URL: $url, error: $error");
                                    return Container(
                                      color: Colors.grey[700],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                size: 40),
                                            const SizedBox(height: 8),
                                            Text('Image not found',
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.7))),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                  child: Text(
                                    movie.originalTitle ??
                                        movie.title ??
                                        'No Title',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: height * 0.70,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      enlargeCenterPage: true,
                      viewportFraction: 0.90,
                      enableInfiniteScroll: true,
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: height * 0.70,
                  child: const Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent)),
                ),
                error: (error, stack) => SizedBox(
                  height: height * 0.70,
                  child: Center(
                      child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  )),
                ),
              ),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      categoryChip(ref, 'nowPlaying', 'Now Playing'),
                      categoryChip(ref, 'popular', 'Popular'),
                      categoryChip(ref, 'topRated', 'Top Rated'),
                      categoryChip(ref, 'upComing', 'Upcoming'),
                      categoryChip(ref, 'hindi', 'Hindi'),
                      categoryChip(ref, 'english', 'English'),
                    ],
                  ),
                ),
              ),
              // GridView for other movie lists
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 110),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: moviesList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.47,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final movie = moviesList[index];
                    return GestureDetector(
                        onTap: () async {
                          await _navigateToMovieDetails(context, ref, movie);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 300,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: CachedNetworkImage(
                                  imageUrl: '$imageUrl${movie.posterPath}',
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.blueAccent),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              movie.originalTitle ?? movie.title ?? 'No Title',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  double rating = (movie.imdb ?? 0) / 2;
                                  if (index < rating.floor()) {
                                    return Icon(Icons.star,
                                        color: Colors.yellow[800], size: 16);
                                  } else if (index < rating &&
                                      rating - index >= 0.5) {
                                    return Icon(Icons.star_half,
                                        color: Colors.yellow[800], size: 16);
                                  } else {
                                    return Icon(Icons.star_border,
                                        color: Colors.yellow[800], size: 16);
                                  }
                                }),
                              ],
                            )
                          ],
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryChip(WidgetRef ref, String value, String label) {
    final selected = ref.watch(selectedCategoryProvider);
    final isSelected = selected == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.yellow[800],
        backgroundColor: Colors.grey[700],
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) {
          ref.read(selectedCategoryProvider.notifier).state = value;
          ref.read(movieProvider.notifier).fetchMovies(value);
        },
      ),
    );
  }
}
