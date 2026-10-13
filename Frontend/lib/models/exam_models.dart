class ExamSummary {
  final int id;
  final String title;
  final String code;
  final int durationMinutes;
  final int totalQuestions;
  final String? description;
  final bool isActive;

  ExamSummary({
    required this.id,
    required this.title,
    required this.code,
    required this.durationMinutes,
    required this.totalQuestions,
    this.description,
    required this.isActive,
  });

  factory ExamSummary.fromJson(Map<String, dynamic> json) {
    return ExamSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 75,
      totalQuestions: json['totalQuestions'] ?? 100,
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class ExamDetail {
  final int id;
  final String title;
  final String code;
  final int durationMinutes;
  final int totalQuestions;
  final List<ExamPartData> parts;

  ExamDetail({
    required this.id,
    required this.title,
    required this.code,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.parts,
  });

  factory ExamDetail.fromJson(Map<String, dynamic> json) {
    var rawParts = json['parts'] as List? ?? [];
    List<ExamPartData> partsList =
        rawParts.map((p) => ExamPartData.fromJson(p)).toList();

    return ExamDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 75,
      totalQuestions: json['totalQuestions'] ?? 100,
      parts: partsList,
    );
  }

  /// Lấy toàn bộ 100 câu hỏi phẳng theo thứ tự số câu tăng dần
  List<QuestionData> getAllQuestions() {
    List<QuestionData> list = [];
    for (var part in parts) {
      if (part.partNumber == 5) {
        list.addAll(part.independentQuestions);
      } else {
        for (var grp in part.groups) {
          list.addAll(grp.questions);
        }
      }
    }
    list.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return list;
  }
}

class ExamPartData {
  final int id;
  final int partNumber;
  final String name;
  final int totalQuestions;
  final List<PassageGroupData> groups;
  final List<QuestionData> independentQuestions;

  ExamPartData({
    required this.id,
    required this.partNumber,
    required this.name,
    required this.totalQuestions,
    required this.groups,
    required this.independentQuestions,
  });

  factory ExamPartData.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['groups'] as List? ?? [];
    var rawIndep = json['independentQuestions'] as List? ?? [];

    return ExamPartData(
      id: json['id'] ?? 0,
      partNumber: json['partNumber'] ?? 5,
      name: json['name'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      groups: rawGroups.map((g) => PassageGroupData.fromJson(g)).toList(),
      independentQuestions:
          rawIndep.map((q) => QuestionData.fromJson(q)).toList(),
    );
  }
}

class PassageGroupData {
  final int id;
  final String groupCode;
  final String? groupTitle;
  final String passageText;
  final String? imageUrl;
  final int orderIndex;
  final List<QuestionData> questions;

  PassageGroupData({
    required this.id,
    required this.groupCode,
    this.groupTitle,
    required this.passageText,
    this.imageUrl,
    required this.orderIndex,
    required this.questions,
  });

  factory PassageGroupData.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List? ?? [];
    return PassageGroupData(
      id: json['id'] ?? 0,
      groupCode: json['groupCode'] ?? '',
      groupTitle: json['groupTitle'],
      passageText: json['passageText'] ?? '',
      imageUrl: json['imageUrl'],
      orderIndex: json['orderIndex'] ?? 0,
      questions: rawQuestions
          .map((q) => QuestionData.fromJson(q, passageText: json['passageText']))
          .toList(),
    );
  }
}

class QuestionData {
  final int id;
  final int questionNumber;
  final String questionText;
  final String correctOption;
  final int? passageGroupId;
  final String? passageText;
  final List<AnswerOptionData> options;

  QuestionData({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    required this.correctOption,
    this.passageGroupId,
    this.passageText,
    required this.options,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json,
      {String? passageText}) {
    var rawOptions = json['options'] as List? ?? [];
    return QuestionData(
      id: json['id'] ?? 0,
      questionNumber: json['questionNumber'] ?? 0,
      questionText: json['questionText'] ?? '',
      correctOption: json['correctOption'] ?? '',
      passageGroupId: json['passageGroupId'],
      passageText: passageText,
      options: rawOptions.map((o) => AnswerOptionData.fromJson(o)).toList(),
    );
  }
}

class AnswerOptionData {
  final int id;
  final String optionLabel;
  final String optionText;
  final bool isCorrect;

  AnswerOptionData({
    required this.id,
    required this.optionLabel,
    required this.optionText,
    required this.isCorrect,
  });

  factory AnswerOptionData.fromJson(Map<String, dynamic> json) {
    return AnswerOptionData(
      id: json['id'] ?? 0,
      optionLabel: json['optionLabel'] ?? '',
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}

class SubmitExamResultData {
  final int attemptId;
  final int examId;
  final String studentName;
  final String studentCode;
  final int totalQuestions;
  final int totalCorrect;
  final int totalIncorrect;
  final int totalSkipped;
  final int score;
  final String status;
  final DateTime submitTime;

  SubmitExamResultData({
    required this.attemptId,
    required this.examId,
    required this.studentName,
    required this.studentCode,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalSkipped,
    required this.score,
    required this.status,
    required this.submitTime,
  });

  factory SubmitExamResultData.fromJson(Map<String, dynamic> json) {
    return SubmitExamResultData(
      attemptId: json['attemptId'] ?? 0,
      examId: json['examId'] ?? 0,
      studentName: json['studentName'] ?? '',
      studentCode: json['studentCode'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 100,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalIncorrect: json['totalIncorrect'] ?? 0,
      totalSkipped: json['totalSkipped'] ?? 0,
      score: json['score'] ?? 0,
      status: json['status'] ?? 'Submitted',
      submitTime: json['submitTime'] != null
          ? DateTime.tryParse(json['submitTime']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
