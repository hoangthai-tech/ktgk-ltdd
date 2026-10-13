import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/exam_models.dart';

class ApiService {
  // Tự động điều chỉnh BaseUrl tùy theo môi trường chạy
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/examapi';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Máy ảo Android dùng 10.0.2.2 để gọi localhost của máy chủ Windows
      return 'http://10.0.2.2:5000/api/examapi';
    } else {
      return 'http://localhost:5000/api/examapi';
    }
  }

  /// 1. Lấy danh sách đề thi (GET /api/examapi/list)
  static Future<List<ExamSummary>> getExamList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/list'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => ExamSummary.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi máy chủ: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching exam list: $e');
      rethrow;
    }
  }

  /// 2. Lấy chi tiết đề thi gồm 100 câu hỏi (GET /api/examapi/{id})
  static Future<ExamDetail> getExamDetail(int examId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$examId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        return ExamDetail.fromJson(data);
      } else {
        throw Exception('Không tìm thấy đề thi (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching exam detail: $e');
      rethrow;
    }
  }

  /// 3. Nộp bài thi và chấm điểm (POST /api/examapi/submit)
  static Future<SubmitExamResultData> submitExam({
    required int examId,
    required String studentName,
    required String studentCode,
    required Map<int, String?> answers,
  }) async {
    try {
      // Chuyển đổi Map<int, String?> sang dạng JSON { "101": "B", ... }
      Map<String, String?> answerMap = {};
      answers.forEach((key, val) {
        answerMap[key.toString()] = val;
      });

      final payload = json.encode({
        'examId': examId,
        'studentName': studentName,
        'studentCode': studentCode,
        'answers': answerMap,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        return SubmitExamResultData.fromJson(data);
      } else {
        throw Exception('Lỗi nộp bài thi (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error submitting exam: $e');
      rethrow;
    }
  }

  /// 4. Lấy danh sách kết quả bài thi của học sinh cho Admin (GET /api/examapi/attempts)
  static Future<List<SubmitExamResultData>> getExamAttempts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attempts'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => SubmitExamResultData.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi máy chủ: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching attempts: $e');
      rethrow;
    }
  }
}
