import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'exam_list_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExamProvider>(context, listen: false);
    final result = provider.examResult;
    final questions = provider.allQuestions;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả thi')),
        body: const Center(child: Text('Không tìm thấy dữ liệu kết quả thi!')),
      );
    }

    final accuracyPercent = result.totalQuestions > 0
        ? (result.totalCorrect / result.totalQuestions * 100).toStringAsFixed(1)
        : '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'KẾT QUẢ THI TOEIC READING',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Thẻ Bảng Điểm Tổng Quan
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B365D), Color(0xFF0066CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      size: 54,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.studentName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'MSSV: ${result.studentCode}  |  Lớp: ${provider.studentClass}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 28),
                    // Điểm TOEIC Reading ước tính
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${result.score}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '/ 495 điểm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tỷ lệ chính xác: $accuracyPercent%',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Thống kê 3 chỉ số: Đúng / Sai / Bỏ qua
            Row(
              children: [
                _buildStatBox(
                  label: 'Số câu Đúng',
                  count: result.totalCorrect,
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF28A745),
                  bgColor: Colors.green.shade50,
                ),
                const SizedBox(width: 10),
                _buildStatBox(
                  label: 'Số câu Sai',
                  count: result.totalIncorrect,
                  icon: Icons.cancel_outlined,
                  color: const Color(0xFFDC3545),
                  bgColor: Colors.red.shade50,
                ),
                const SizedBox(width: 10),
                _buildStatBox(
                  label: 'Bỏ qua',
                  count: result.totalSkipped,
                  icon: Icons.help_outline,
                  color: Colors.orange.shade800,
                  bgColor: Colors.orange.shade50,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. Chi tiết từng câu hỏi (Review Answers)
            Row(
              children: const [
                Icon(Icons.fact_check_outlined, color: Color(0xFF1B365D)),
                SizedBox(width: 8),
                Text(
                  'Chi tiết từng câu hỏi (101 - 200)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B365D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, idx) {
                final q = questions[idx];
                final studentAns = provider.selectedAnswers[q.questionNumber];
                final isCorrect =
                    studentAns != null && studentAns == q.correctOption;
                final isSkipped = studentAns == null || studentAns.isEmpty;

                Color statusColor;
                IconData statusIcon;
                String statusText;

                if (isCorrect) {
                  statusColor = const Color(0xFF28A745);
                  statusIcon = Icons.check_circle;
                  statusText = 'ĐÚNG';
                } else if (isSkipped) {
                  statusColor = Colors.orange;
                  statusIcon = Icons.remove_circle_outline;
                  statusText = 'BỎ QUA';
                } else {
                  statusColor = const Color(0xFFDC3545);
                  statusIcon = Icons.cancel;
                  statusText = 'SAI';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        // Cột 1: Số câu
                        Container(
                          width: 65,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B365D),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Câu ${q.questionNumber}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Cột 2: Lựa chọn của thí sinh
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Bạn chọn: ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    studentAns != null ? '($studentAns)' : 'Chưa làm',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: studentAns != null
                                          ? (isCorrect
                                              ? const Color(0xFF28A745)
                                              : const Color(0xFFDC3545))
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isCorrect)
                                Row(
                                  children: [
                                    Text(
                                      'Đáp án đúng: ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      '(${q.correctOption})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF28A745),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Cột 3: Trạng thái Đúng/Sai
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Nút Quay lại
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExamListScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text(
                  'VỀ DANH SÁCH ĐỀ THI',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
