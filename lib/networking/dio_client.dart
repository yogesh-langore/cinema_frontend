import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_cinema/models/cinema.dart';
import 'package:flutter_cinema/utils/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<Response> get(String? queryParamValue) async {
    final url = "$apiUrl$movieUrl?type=$queryParamValue";
    try {
      final response = await _dio.get(url);
      return response;
    } catch (e, stackTrace) {
      log("GET failed: $e", stackTrace: stackTrace, name: "DioClient.get");
      throw Exception("GET failed: $e");
    }
  }

  Future<void> delete(String id) async {
    try {
      final response = await _dio.delete("$apiUrl$movieUrl/$id");
      log("Deleted: ${response.data}", name: "DioClient.delete");
    } catch (e, stackTrace) {
      log("Delete failed: $e",
          stackTrace: stackTrace, name: "DioClient.delete");
      throw Exception("DELETE failed: $e");
    }
  }

  Future<void> updateMovie(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("$apiUrl$movieUrl/$id", data: data);
      log("Updated: ${response.data}", name: "DioClient.updateMovie");
    } catch (e, stackTrace) {
      log("Update failed: $e",
          stackTrace: stackTrace, name: "DioClient.updateMovie");
      throw Exception("Update failed: $e");
    }
  }

  Future<Result> createMovie(Map<String, dynamic> movieData) async {
    try {
      final response = await _dio.post("$apiUrl$movieUrl", data: movieData);
      log("Created Movie Response: ${response.data}",
          name: "DioClient.createMovie");

      // Directly parse the response data into a Result object
      // The backend is already sending the full movie object with 'id'
      if (response.statusCode == 200 && response.data != null) {
        // Ensure response.data is a Map<String, dynamic> for fromJson
        if (response.data is Map<String, dynamic>) {
          return Result.fromJson(response.data as Map<String, dynamic>);
        } else {
          throw Exception(
              "Invalid response format: Expected a map for created movie.");
        }
      } else {
        throw Exception(
            "Failed to create movie: Server returned status ${response.statusCode}");
      }
    } on DioException catch (e) {
      log("Create failed: ${e.message}",
          stackTrace: e.stackTrace, name: "DioClient.createMovie");
      throw Exception("Create failed: ${e.message}");
    } catch (e, stackTrace) {
      log("Create failed (unexpected): $e",
          stackTrace: stackTrace, name: "DioClient.createMovie");
      throw Exception("An unexpected error occurred during creation: $e");
    }
  }

  Future<Response> searchMovies(String query) async {
    const url = "${apiUrl}search/movie";
    try {
      final response = await _dio.get(url, queryParameters: {
        'query': query,
      });
      log("Search Response Data: ${response.data}");
      return response;
    } catch (e, stackTrace) {
      log("Search failed: $e",
          stackTrace: stackTrace, name: "DioClient.searchMovies");
      throw Exception("Search failed: $e");
    }
  }
}

final dioProvider = Provider((ref) => DioClient());
