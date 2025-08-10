// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cinema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResultAdapter extends TypeAdapter<Result> {
  @override
  final int typeId = 1;

  @override
  Result read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Result(
      id: fields[0] as String?,
      originalTitle: fields[1] as String?,
      title: fields[2] as String?,
      originalLanguage: fields[3] as String?,
      backdropPath: fields[4] as String?,
      posterPath: fields[5] as String?,
      genres: (fields[6] as List?)?.cast<String>(),
      overview: fields[7] as String?,
      releaseDate: fields[8] as int?,
      runTime: fields[9] as String?,
      imdb: fields[10] as double?,
      seasons: fields[11] as int?,
      episodes: fields[12] as int?,
      foundIn: (fields[13] as List).cast<String>(),
      cast: (fields[14] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Result obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalTitle)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.originalLanguage)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.posterPath)
      ..writeByte(6)
      ..write(obj.genres)
      ..writeByte(7)
      ..write(obj.overview)
      ..writeByte(8)
      ..write(obj.releaseDate)
      ..writeByte(9)
      ..write(obj.runTime)
      ..writeByte(10)
      ..write(obj.imdb)
      ..writeByte(11)
      ..write(obj.seasons)
      ..writeByte(12)
      ..write(obj.episodes)
      ..writeByte(13)
      ..write(obj.foundIn)
      ..writeByte(14)
      ..write(obj.cast);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
      id: json['id'] as String?,
      originalTitle: json['original_title'] as String?,
      title: json['title'] as String?,
      originalLanguage: json['original_language'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      posterPath: json['poster_path'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      overview: json['overview'] as String?,
      releaseDate: (json['release_date'] as num?)?.toInt(),
      runTime: json['run_time'] as String?,
      imdb: (json['imdb'] as num?)?.toDouble(),
      seasons: (json['seasons'] as num?)?.toInt(),
      episodes: (json['episodes'] as num?)?.toInt(),
      foundIn:
          (json['foundIn'] as List<dynamic>).map((e) => e as String).toList(),
      cast: (json['cast'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'id': instance.id,
      'original_title': instance.originalTitle,
      'title': instance.title,
      'original_language': instance.originalLanguage,
      'backdrop_path': instance.backdropPath,
      'poster_path': instance.posterPath,
      'genres': instance.genres,
      'overview': instance.overview,
      'release_date': instance.releaseDate,
      'run_time': instance.runTime,
      'imdb': instance.imdb,
      'seasons': instance.seasons,
      'episodes': instance.episodes,
      'foundIn': instance.foundIn,
      'cast': instance.cast,
    };
