import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cinema.g.dart';

@JsonSerializable()
@HiveType(typeId: 01)
class Result {
  @HiveField(0)
  final String? id;

  @JsonKey(name: 'original_title')
  @HiveField(1)
  final String? originalTitle;

  @JsonKey(name: 'title')
  @HiveField(2)
  final String? title;

  @JsonKey(name: 'original_language')
  @HiveField(3)
  final String? originalLanguage;

  @JsonKey(name: 'backdrop_path')
  @HiveField(4)
  final String? backdropPath;

  @JsonKey(name: 'poster_path')
  @HiveField(5)
  final String? posterPath;

  @JsonKey(name: 'genres')
  @HiveField(6)
  final List<String>? genres;

  @JsonKey(name: 'overview')
  @HiveField(7)
  final String? overview;

  @JsonKey(name: 'release_date')
  @HiveField(8)
  final int? releaseDate;

  @JsonKey(name: 'run_time')
  @HiveField(9)
  final String? runTime;

  @JsonKey(name: 'imdb')
  @HiveField(10)
  final double? imdb;

  @JsonKey(name: 'seasons')
  @HiveField(11)
  final int? seasons;

  @JsonKey(name: 'episodes')
  @HiveField(12)
  final int? episodes;

  @JsonKey(name: 'foundIn')
  @HiveField(13)
  final List<String> foundIn;

  @JsonKey(name: 'cast')
  @HiveField(14)
  final List<Map<String, dynamic>>? cast;

  Result({
    this.id,
    this.originalTitle,
    this.title,
    this.originalLanguage,
    this.backdropPath,
    this.posterPath,
    this.genres,
    this.overview,
    this.releaseDate,
    this.runTime,
    this.imdb,
    this.seasons,
    this.episodes,
    required this.foundIn,
    this.cast,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id']?.toString(),
      originalTitle: json['original_title'] as String?,
      title: json['title'] as String?,
      originalLanguage: json['original_language'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      posterPath: json['poster_path'] as String?,
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList(),
      overview: json['overview'] as String?,
      releaseDate: json['release_date'] as int?,
      runTime: json['run_time'] as String?,
      imdb: json['imdb'] as double?,
      seasons: json['seasons'] as int?,
      episodes: json['episodes'] as int?,
      foundIn:
          (json['foundIn'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cast: (json['cast'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$ResultToJson(this);

  Result copyWith({
    String? id,
    String? originalTitle,
    String? title,
    String? originalLanguage,
    String? backdropPath,
    String? posterPath,
    List<String>? genres,
    String? overview,
    int? releaseDate,
    String? runTime,
    double? imdb,
    int? seasons,
    int? episodes,
    List<String>? foundIn,
    List<Map<String, dynamic>>? cast,
  }) {
    return Result(
      id: id ?? this.id,
      originalTitle: originalTitle ?? this.originalTitle,
      title: title ?? this.title,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      backdropPath: backdropPath ?? this.backdropPath,
      posterPath: posterPath ?? this.posterPath,
      genres: genres ?? this.genres,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      runTime: runTime ?? this.runTime,
      imdb: imdb ?? this.imdb,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      foundIn: foundIn ?? this.foundIn,
      cast: cast ?? this.cast,
    );
  }
}
