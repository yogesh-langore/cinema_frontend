import 'dart:async'; // Import for Timer
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cinema/presentation/screens/movies_details_screen.dart';
import 'package:flutter_cinema/providers/search_providers.dart';
import 'package:flutter_cinema/utils/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Converted to ConsumerStatefulWidget to handle the debouncing timer
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // To update the clear button visibility
    });
  }

  // Dispose the timer when the widget is removed from the tree to prevent memory leaks
  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // This function is called on every keystroke in the TextField
  void _onSearchChanged(String query) {
    // If there's an active timer, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Start a new timer. The search query provider will only be updated
    // after the user has stopped typing for 500 milliseconds.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final asyncData = ref.watch(movieSearchProvider(query));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: TextField(
                  controller: _controller,
                  // Use the debounced function
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Movies, series, shows...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: asyncData.when(
                  data: (movies) {
                    // Show a message if the search term is not empty but no results were found
                    if (movies.isEmpty && query.isNotEmpty) {
                      return const Center(
                        child: Text("No movies found.",
                            style: TextStyle(color: Colors.white)),
                      );
                    }
                    // Show an initial message before the user starts searching
                    if (query.isEmpty) {
                      return const Center(
                        child: Text("Search for a movie to get started!",
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    return ListView.builder(
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(result: movie),
                            ));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 51, 28, 28),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: '$imageUrl${movie.posterPath}',
                                    height: 100,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[800]),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error,
                                            color: Colors.red),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title ??
                                            movie.originalTitle ??
                                            'No Title',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        movie.overview?.isNotEmpty == true
                                            ? movie.overview!
                                            : 'No overview available.',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: List.generate(5, (index) {
                                          double rating = (movie.imdb ?? 0) / 2;
                                          if (index < rating.floor()) {
                                            return Icon(Icons.star,
                                                color: Colors.yellow[800],
                                                size: 16);
                                          } else if (index < rating &&
                                              rating - index >= 0.5) {
                                            return Icon(Icons.star_half,
                                                color: Colors.yellow[800],
                                                size: 16);
                                          } else {
                                            return Icon(Icons.star_border,
                                                color: Colors.yellow[800],
                                                size: 16);
                                          }
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (e, _) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
