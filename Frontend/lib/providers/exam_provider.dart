import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exam_models.dart';
import '../services/api_service.dart';

class ExamProvider with ChangeNotifier {
  ExamDetail? _currentExam;
  List<QuestionData> _allQuestions = [];
  int _currentIndex = 0;

  String _studentName = 'Dương Hoàng Thái';
  String _studentCode = '2380602012';
  String _studentClass = '23DTHC7';

  // Map lưu đáp án chọn: QuestionNumber -> 'A' | 'B' | 'C' | 'D' | null
  final Map<int, String?> _selectedAnswers = {};

  // Đồng hồ đếm ngược 75 phút = 4500 giây
  int _remainingSeconds = 75 * 60;
  Timer? _countdownTimer;
  bool _isTimerRunning = false;
  bool _isSubmitting = false;
  bool _isTimeOut = false;
  SubmitExamResultData? _examResult;

  // Getters
  ExamDetail? get currentExam => _currentExam;
  List<QuestionData> get allQuestions => _allQuestions;
  int get currentIndex => _currentIndex;
  String get studentName => _studentName;
  String get studentCode => _studentCode;
  String get studentClass => _studentClass;
  Map<int, String?> get selectedAnswers => _selectedAnswers;
  int get remainingSeconds => _remainingSeconds;
  bool get isTimerRunning => _isTimerRunning;
  bool get isSubmitting => _isSubmitting;
  bool get isTimeOut => _isTimeOut;
  SubmitExamResultData? get examResult => _examResult;

  QuestionData? get currentQuestion =>
      _allQuestions.isNotEmpty && _currentIndex < _allQuestions.length
          ? _allQuestions[_currentIndex]
          : null;

  int get totalAnswered =>
      _selectedAnswers.values.where((v) => v != null && v.isNotEmpty).length;

  int get totalQuestions => _allQuestions.length;

  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void setStudentInfo(String name, String code, [String className = '23DTHC7']) {
    _studentName = name;
    _studentCode = code;
    _studentClass = className;
    notifyListeners();
  }

  /// Khởi tạo bài thi và bắt đầu đếm ngược 75 phút
  void startExam(ExamDetail exam, String name, String code,
      [String className = '23DTHC7']) {
    _currentExam = exam;
    _allQuestions = exam.getAllQuestions();
    _currentIndex = 0;
    _studentName = name;
    _studentCode = code;
    _studentClass = className;
    _selectedAnswers.clear();
    _isTimeOut = false;
    _examResult = null;

    // Thiết lập thời gian (75 phút)
    _remainingSeconds = exam.durationMinutes * 60;

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _isTimerRunning = true;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
        _isTimerRunning = false;
        _isTimeOut = true;
        notifyListeners();
        // Tự động thu bài khi hết giờ
        submitExamAuto();
      }
    });
  }

  /// Chọn đáp án hoặc hủy chọn (nếu bấm lại vào đáp án đã chọn)
  void selectAnswer(int questionNumber, String option) {
    if (_isTimeOut || _examResult != null) return; // Đã hết giờ hoặc đã nộp

    if (_selectedAnswers[questionNumber] == option) {
      // Hủy chọn
      _selectedAnswers[questionNumber] = null;
    } else {
      _selectedAnswers[questionNumber] = option;
    }
    notifyListeners();
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _allQuestions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _allQuestions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Nộp bài thủ công
  Future<SubmitExamResultData?> submitExam() async {
    if (_currentExam == null || _isSubmitting) return null;

    _isSubmitting = true;
    notifyListeners();

    try {
      _countdownTimer?.cancel();
      _isTimerRunning = false;

      final result = await ApiService.submitExam(
        examId: _currentExam!.id,
        studentName: _studentName,
        studentCode: _studentCode,
        answers: _selectedAnswers,
      );

      _examResult = result;
      _isSubmitting = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Tự động nộp bài khi hết giờ (TimeOut)
  Future<void> submitExamAuto() async {
    if (_currentExam == null || _examResult != null) return;

    try {
      final result = await ApiService.submitExam(
        examId: _currentExam!.id,
        studentName: _studentName,
        studentCode: _studentCode,
        answers: _selectedAnswers,
      );
      _examResult = result;
      notifyListeners();
    } catch (e) {
      debugPrint('Auto submit failed: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
