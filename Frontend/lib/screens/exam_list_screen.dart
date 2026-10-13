import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_models.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';
import 'admin_dashboard_screen.dart';
import 'exam_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  late Future<List<ExamSummary>> _examsFuture;
  final TextEditingController _nameController =
      TextEditingController(text: 'Dương Hoàng Thái');
  final TextEditingController _codeController =
      TextEditingController(text: '2380602012');
  final TextEditingController _classController =
      TextEditingController(text: '23DTHC7');
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  void _loadExams() {
    setState(() {
      _examsFuture = ApiService.getExamList();
    });
  }

  Future<void> _startExam(ExamSummary examSummary) async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final className = _classController.text.trim();

    if (name.isEmpty || code.isEmpty || className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ Họ tên, MSSV và Lớp!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final examDetail = await ApiService.getExamDetail(examSummary.id);

      if (!mounted) return;

      final provider = Provider.of<ExamProvider>(context, listen: false);
      provider.startExam(examDetail, name, code, className);

      setState(() {
        _isLoadingDetail = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExamScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDetail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu đề thi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'HỆ THỐNG THI TOEIC READING',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại danh sách',
            onPressed: _loadExams,
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            },
            icon: const Icon(Icons.admin_panel_settings,
                color: Colors.amber, size: 18),
            label: const Text(
              'Admin',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khối thông tin Thí sinh
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person, color: Color(0xFF1B365D)),
                            SizedBox(width: 8),
                            Text(
                              'Thông tin Thí sinh dự thi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B365D),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên thí sinh',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _codeController,
                                decoration: const InputDecoration(
                                  labelText: 'Mã số sinh viên (MSSV)',
                                  prefixIcon: Icon(Icons.numbers),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _classController,
                                decoration: const InputDecoration(
                                  labelText: 'Lớp học',
                                  prefixIcon: Icon(Icons.class_outlined),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Danh sách đề thi từ API
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Danh sách đề thi khả dụng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      'Chuẩn ETS TOEIC',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<ExamSummary>>(
                  future: _examsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Card(
                        color: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                'Không thể kết nối đến Backend: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _loadExams,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final exams = snapshot.data ?? [];

                    if (exams.isEmpty) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.folder_open,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Hiện chưa có đề thi nào trong hệ thống!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exams.length,
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFD6E4FF),
                              width: 1.5,
                            ),
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
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B365D),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        exam.code,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.green.shade300),
                                      ),
                                      child: const Text(
                                        'Chính thức',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  exam.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B365D),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildBadge(
                                      Icons.list_alt,
                                      '${exam.totalQuestions} câu hỏi',
                                      Colors.blue.shade700,
                                      Colors.blue.shade50,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      Icons.timer_outlined,
                                      '${exam.durationMinutes} phút',
                                      Colors.orange.shade800,
                                      Colors.orange.shade50,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      Icons.layers_outlined,
                                      'Part 5-6-7',
                                      Colors.teal.shade700,
                                      Colors.teal.shade50,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _startExam(exam),
                                    icon: const Icon(Icons.play_circle_fill),
                                    label: const Text(
                                      'BẮT ĐẦU LÀM BÀI THI',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0066CC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isLoadingDetail)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải 100 câu hỏi và các bài đọc...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(
      IconData icon, String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
