import 'package:flutter/material.dart';
import 'package:flutter_cinema/networking/dio_client.dart';
import 'package:flutter_cinema/providers/movie_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateMovieScreen extends ConsumerStatefulWidget {
  const CreateMovieScreen({super.key});

  @override
  ConsumerState<CreateMovieScreen> createState() => _CreateMovieScreenState();
}

class _CreateMovieScreenState extends ConsumerState<CreateMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final overviewController = TextEditingController();
  final languageController = TextEditingController();
  final runTimeController = TextEditingController();
  final imdbController = TextEditingController();
  final releaseDateController = TextEditingController();
  final backdropController = TextEditingController();
  final genresController = TextEditingController();
  final foundInController = TextEditingController();
  final posterpathController = TextEditingController();

  // TV series fields
  final seasonsController = TextEditingController();
  final episodesController = TextEditingController();

  bool _isLoading = false;
  String _selectedType = 'movie'; // 'movie' or 'tv'

  @override
  void dispose() {
    titleController.dispose();
    overviewController.dispose();
    languageController.dispose();
    runTimeController.dispose();
    imdbController.dispose();
    releaseDateController.dispose();
    backdropController.dispose();
    genresController.dispose();
    foundInController.dispose();
    posterpathController.dispose();
    seasonsController.dispose();
    episodesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final movieData = <String, dynamic>{
      "original_title": titleController.text.trim(),
      "overview": overviewController.text.trim(),
      "original_language": languageController.text.trim(),
      "run_time": runTimeController.text.trim(),
      "imdb": double.tryParse(imdbController.text.trim()) ?? 0.0,
      "release_date": int.tryParse(releaseDateController.text.trim()) ?? 0,
      "poster_path": posterpathController.text.trim(),
      "backdrop_path": backdropController.text.trim(),
      "genres": genresController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      "foundIn": foundInController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      // media type so backend knows (optional, but useful)
      "type": _selectedType, // 'movie' or 'tv'
    };

    // only include seasons/episodes if TV Series
    if (_selectedType == 'tv') {
      final seasonsText = seasonsController.text.trim();
      final episodesText = episodesController.text.trim();
      if (seasonsText.isNotEmpty) {
        movieData['seasons'] = int.tryParse(seasonsText) ?? 0;
      } else {
        movieData['seasons'] = 0;
      }
      if (episodesText.isNotEmpty) {
        movieData['episodes'] = int.tryParse(episodesText) ?? 0;
      } else {
        movieData['episodes'] = 0;
      }
    }

    try {
      final movie = await ref.read(dioProvider).createMovie(movieData);
      // Add to local state for each foundIn type so UI updates instantly
      for (final type in movie.foundIn) {
        ref.read(movieProvider.notifier).addMovieToState(movie, type);
      }

      _showSuccessSnackBar(
        _selectedType == 'tv'
            ? "TV Series created successfully"
            : "Movie created successfully",
      );
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(
          "Failed to create ${_selectedType == 'tv' ? 'TV Series' : 'Movie'}: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTv = _selectedType == 'tv';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _selectedType == 'tv' ? 'Create New TV Series' : 'Create New Movie',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard([
                // Type selector
                Row(
                  children: [
                    const Icon(Icons.movie_outlined, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text("Type", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedType,
                      dropdownColor: Colors.grey[900],
                      items: const [
                        DropdownMenuItem(
                            value: 'movie',
                            child: Text(
                              'Movie',
                              style: TextStyle(color: Colors.white),
                            )),
                        DropdownMenuItem(
                            value: 'tv',
                            child: Text(
                              'TV Series',
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _selectedType = v;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: titleController,
                  labelText:
                      _selectedType == 'tv' ? 'Series Title' : 'Movie Title',
                  icon: Icons.title,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: overviewController,
                  labelText: 'Overview',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Overview is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: languageController,
                  labelText: 'Language',
                  icon: Icons.language,
                  hintText: 'English, Hindi, Marathi',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Language is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: runTimeController,
                  labelText: 'Runtime (Example: 2h 37m)',
                  icon: Icons.timer,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Runtime is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: imdbController,
                  labelText: 'IMDB Rating (1-10)',
                  icon: Icons.star,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty == true ? 'IMDB Rating is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: releaseDateController,
                  labelText: "Release Date (Only Enter Year)",
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty == true
                      ? 'Release Date is required'
                      : null,
                  icon: Icons.calendar_month,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: posterpathController,
                  labelText: 'Poster URL',
                  icon: Icons.image,
                  hintText: 'https://image.tmdb.org/t/p/original',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Poster URL is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: backdropController,
                  labelText: 'Backdrop URL',
                  icon: Icons.wallpaper,
                  hintText: 'https://image.tmdb.org/t/p/original',
                  validator: (value) => value?.isEmpty == true
                      ? 'Backdrop URL is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: genresController,
                  labelText: 'Genres (comma separated)',
                  icon: Icons.category,
                  hintText: 'Action, Drama, Comedy',
                  validator: (value) => value?.isEmpty == true
                      ? 'At least one genre is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: foundInController,
                  labelText: 'Found In (comma separated)',
                  icon: Icons.source,
                  hintText: _selectedType == 'movie'
                      ? 'nowPlaying, topRated, upComing'
                      : 'hindi, english',
                  validator: (value) => value?.isEmpty == true
                      ? 'At least one source is required'
                      : null,
                ),

                // If TV series selected, show seasons & episodes
                if (isTv) ...[
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: seasonsController,
                    labelText: 'Seasons (number)',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (isTv && (value?.isEmpty ?? true)) {
                        return 'Seasons is required for TV Series';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: episodesController,
                    labelText: 'Episodes (number)',
                    icon: Icons.confirmation_num,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (isTv && (value?.isEmpty ?? true)) {
                        return 'Episodes is required for TV Series';
                      }
                      return null;
                    },
                  ),
                ],
              ]),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedType == 'tv'
                                  ? 'Creating TV Series...'
                                  : 'Creating Movie...',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle,
                                size: 24, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              _selectedType == 'tv'
                                  ? 'Create TV Series'
                                  : 'Create Movie',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[850],
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
