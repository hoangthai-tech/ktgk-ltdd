import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'result_screen.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, child) {
        final q = provider.currentQuestion;

        if (q == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isTimeLow = provider.remainingSeconds < 300; // Dưới 5 phút

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B365D),
            foregroundColor: Colors.white,
            elevation: 2,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPartName(q.questionNumber),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Câu ${q.questionNumber} / 200  (${provider.currentIndex + 1}/100)',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                // Đồng hồ đếm ngược
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTimeLow
                        ? Colors.redAccent
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTimeLow ? Colors.yellow : Colors.white30,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: isTimeLow ? Colors.yellow : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isTimeLow ? Colors.white : Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: 'Bảng câu hỏi',
                onPressed: () => _showQuestionPalette(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                tooltip: 'Nộp bài',
                onPressed: () => _confirmSubmit(context, provider),
              ),
            ],
          ),
          body: provider.isSubmitting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Đang nộp bài và chấm điểm tự động...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Thanh tiến độ làm bài
                    LinearProgressIndicator(
                      value: provider.totalQuestions > 0
                          ? provider.totalAnswered / provider.totalQuestions
                          : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF28A745)),
                      minHeight: 4,
                    ),

                    // Nội dung câu hỏi + bài đọc (nếu có)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Bài đọc Passage (Part 6 & Part 7)
                            if (q.passageText != null &&
                                q.passageText!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(14.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.menu_book,
                                            size: 16,
                                            color: Color(0xFF1B365D)),
                                        SizedBox(width: 6),
                                        Text(
                                          'Đoạn văn bài đọc (Passage):',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1B365D),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Text(
                                      q.passageText!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.55,
                                        color: Color(0xFF2B2B2B),
                                        fontFamily: 'Segoe UI',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // 2. Nội dung câu hỏi
                            Card(
                              elevation: 1,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1B365D),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Câu ${q.questionNumber}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (provider.selectedAnswers[
                                                q.questionNumber] !=
                                            null)
                                          Text(
                                            'Đã chọn: (${provider.selectedAnswers[q.questionNumber]})',
                                            style: const TextStyle(
                                              color: Color(0xFF28A745),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      q.questionText.isNotEmpty
                                          ? q.questionText
                                          : 'Chọn đáp án thích hợp nhất để điền vào chỗ trống:',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C1C1C),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 3. 4 Phương án lựa chọn A, B, C, D
                            ...q.options.map((opt) {
                              final isSelected = provider.selectedAnswers[
                                      q.questionNumber] ==
                                  opt.optionLabel;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => provider.selectAnswer(
                                      q.questionNumber, opt.optionLabel),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFE8F4FD)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF0066CC)
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue
                                                    .withValues(alpha: 0.15),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      children: [
                                        // Badge nhãn (A, B, C, D)
                                        Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF0066CC)
                                                : Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF0066CC)
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                          child: Text(
                                            opt.optionLabel,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Nội dung phương án
                                        Expanded(
                                          child: Text(
                                            opt.optionText,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? const Color(0xFF0066CC)
                                                  : const Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF0066CC),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Thanh điều hướng câu trước / câu sau ở dưới
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: provider.currentIndex > 0
                                  ? provider.previousQuestion
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios, size: 14),
                              label: const Text('Câu trước'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5A6268),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            // Nút mở Palette ở giữa
                            TextButton.icon(
                              onPressed: () =>
                                  _showQuestionPalette(context, provider),
                              icon: const Icon(Icons.apps, size: 18),
                              label: Text(
                                '${provider.totalAnswered}/100 đã làm',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: provider.currentIndex <
                                      provider.totalQuestions - 1
                                  ? provider.nextQuestion
                                  : null,
                              icon: const Icon(Icons.arrow_forward_ios,
                                  size: 14),
                              label: const Text('Câu tiếp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066CC),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _getPartName(int qNum) {
    if (qNum <= 130) {
      return 'Part 5: Incomplete Sentences';
    } else if (qNum <= 146) {
      return 'Part 6: Text Completion';
    } else {
      return 'Part 7: Reading Comprehension';
    }
  }

  // Bảng chọn nhanh câu hỏi (Question Palette 100 câu)
  void _showQuestionPalette(BuildContext context, ExamProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      const Text(
                        'Bảng câu hỏi (101 - 200)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B365D),
                        ),
                      ),
                      const Spacer(),
                      _legend(Colors.green, 'Đã làm'),
                      const SizedBox(width: 8),
                      _legend(Colors.grey.shade300, 'Chưa làm'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: provider.allQuestions.length,
                    itemBuilder: (context, idx) {
                      final q = provider.allQuestions[idx];
                      final isAnswered =
                          provider.selectedAnswers[q.questionNumber] != null;
                      final isCurrent = idx == provider.currentIndex;

                      Color bgColor = isAnswered
                          ? const Color(0xFF28A745)
                          : Colors.grey.shade200;
                      Color textColor =
                          isAnswered ? Colors.white : Colors.black87;

                      return InkWell(
                        onTap: () {
                          provider.jumpToQuestion(idx);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFF0066CC)
                                  : Colors.transparent,
                              width: isCurrent ? 2.5 : 0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${q.questionNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                              if (isAnswered)
                                Text(
                                  '(${provider.selectedAnswers[q.questionNumber]})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmSubmit(context, provider);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'NỘP BÀI THI NGAY',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // Xác nhận nộp bài thi
  void _confirmSubmit(BuildContext context, ExamProvider provider) {
    final unanswered = provider.totalQuestions - provider.totalAnswered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Xác nhận Nộp bài'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thí sinh: ${provider.studentName} (${provider.studentCode})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Số câu đã làm: ${provider.totalAnswered}/100 câu'),
            if (unanswered > 0)
              Text(
                'Số câu chưa làm: $unanswered câu!',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                'Bạn đã hoàn thành đủ 100/100 câu hỏi.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),
            const Text(
                'Sau khi nộp bài, hệ thống sẽ tự động chấm điểm và bạn không thể sửa lại đáp án. Bạn có chắc chắn muốn nộp?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục làm bài'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final result = await provider.submitExam();
                if (result != null && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResultScreen()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi nộp bài: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đồng ý Nộp bài'),
          ),
        ],
      ),
    );
  }
}
