import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_cinema/utils/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackProvider = Provider((ref) => FeedbackService());

class FeedbackService {
  final Dio _dio = Dio();

  Future<void> submitFeedback({required String userName, required String feedback}) async {
    const url = '${apiUrl}feedback';

    try {
      final response = await _dio.post(
        url,
        data: {
          'userName': userName,
          'feedback': feedback,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit feedback');
      }

      log('Feedback submitted: ${response.data}');
    } catch (e, stackTrace) {
      log('Feedback submission failed: $e',
          stackTrace: stackTrace, name: 'FeedbackService.submitFeedback');
      rethrow;
    }
  }
}
