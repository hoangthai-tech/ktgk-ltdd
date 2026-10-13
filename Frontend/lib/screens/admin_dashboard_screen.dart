import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_models.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';
import 'exam_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ExamSummary> _exams = [];
  List<SubmitExamResultData> _attempts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exams = await ApiService.getExamList();
      final attempts = await ApiService.getExamAttempts();
      setState(() {
        _exams = exams;
        _attempts = attempts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E36),
        foregroundColor: Colors.white,
        elevation: 3,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 16, color: Colors.black87),
                  SizedBox(width: 4),
                  Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'QUẢN TRỊ VIÊN & GIẢNG VIÊN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới dữ liệu',
            onPressed: _loadAdminData,
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.school, color: Colors.lightBlueAccent, size: 18),
            label: const Text(
              'Cổng Học sinh',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.folder_shared), text: 'Quản lý Đề thi'),
            Tab(icon: Icon(Icons.analytics), text: 'Bảng điểm Học sinh'),
            Tab(icon: Icon(Icons.code), text: 'Quy chuẩn Thẻ Tags'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang nạp dữ liệu Quản trị viên...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          'Không thể tải dữ liệu: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadAdminData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExamsTab(),
                    _buildScoresTab(),
                    _buildTagsTab(),
                  ],
                ),
    );
  }

  // TAB 1: QUẢN LÝ ĐỀ THI
  Widget _buildExamsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ thông tin Giảng viên phụ trách
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F1E36), Color(0xFF1B365D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.person, size: 32, color: Color(0xFF0F1E36)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ThS. Giảng viên / Quản trị viên',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dương Hoàng Thái',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'MSSV: 2380602012  •  Lớp: 23DTHC7',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Column(
                      children: [
                        Text('Quyền',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white70)),
                        Text('SuperAdmin',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3 Thống kê nhanh
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.assignment,
                  color: Colors.blue.shade700,
                  label: 'Đề thi trong CSDL',
                  value: '${_exams.length}',
                  subText: 'Đề thi chuẩn',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.people_alt,
                  color: Colors.green.shade700,
                  label: 'Lượt bài nộp',
                  value: '${_attempts.length}',
                  subText: 'Đã chấm điểm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.timer,
                  color: Colors.deepPurple.shade700,
                  label: 'Thời lượng thi',
                  value: '75',
                  subText: 'Phút / 100 câu',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tiêu đề danh sách đề
          Row(
            children: [
              const Icon(Icons.list_alt, color: Color(0xFF1B365D), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Danh sách Ngân hàng Đề thi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B365D),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_exams.length} đề thi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Danh sách các đề thi
          ..._exams.map((exam) => _buildAdminExamCard(exam)),

          const SizedBox(height: 20),

          // Nút liên kết đến Website Admin ASP.NET Boilerplate MVC
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: Colors.blue.shade800),
                    const SizedBox(width: 8),
                    const Text(
                      'Website Quản trị Admin Chuyên sâu (ASP.NET Boilerplate MVC)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Website Backend chạy tại http://localhost:5000/Exam cho phép Giảng viên Upload file Word (.docx), xem Preview chi tiết và Chỉnh sửa câu hỏi trực tiếp trên trình duyệt máy tính.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Địa chỉ Web Admin: http://localhost:5000/Exam',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_browser, size: 16),
                      label: const Text('Truy cập: http://localhost:5000/Exam'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Địa chỉ Upload File: http://localhost:5000/Exam/Upload',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Trang Upload File Word'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: BẢNG ĐIỂM HỌC SINH
  Widget _buildScoresTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFF1B365D), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Lịch sử & Bảng điểm Bài thi của Học sinh',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B365D),
                ),
              ),
              const Spacer(),
              Text(
                'Tổng: ${_attempts.length} bài nộp',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_attempts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('Chưa có học sinh nào nộp bài thi.'),
                ),
              ),
            )
          else
            ..._attempts.map((att) => _buildAttemptCard(att)),
        ],
      ),
    );
  }

  // TAB 3: QUY CHUẨN THẺ TAGS
  Widget _buildTagsTab() {
    final tags = [
      {'tag': '[EXAM] ... [/EXAM]', 'name': 'Thẻ Đề thi', 'desc': 'Khai báo tên đề thi, mã đề, thời lượng làm bài 75 phút.'},
      {'tag': '[PART] ... [/PART]', 'name': 'Thẻ Phần thi', 'desc': 'Phân định rõ ràng Part 5 (Câu 101-130), Part 6 (131-146), Part 7 (147-200).'},
      {'tag': '[GROUP] ... [/GROUP]', 'name': 'Thẻ Nhóm bài đọc', 'desc': 'Định nghĩa cụm câu hỏi phụ thuộc cho Part 6 và Part 7 (Level 2).'},
      {'tag': '[PASSAGE] ... [/PASSAGE]', 'name': 'Thẻ Đoạn văn bài đọc', 'desc': 'Chứa nội dung văn bản bài đọc hiểu hoặc hình ảnh đính kèm.'},
      {'tag': '[QUESTION] ... [/QUESTION]', 'name': 'Thẻ Câu hỏi', 'desc': 'Chứa số thứ tự câu hỏi và nội dung câu hỏi trắc nghiệm.'},
      {'tag': '[A], [B], [C], [D]', 'name': 'Thẻ 4 Phương án', 'desc': 'Bốn đáp án lựa chọn tương ứng cho từng câu hỏi.'},
      {'tag': '[ANSWER]', 'name': 'Thẻ Đáp án đúng', 'desc': 'Chứa ký tự đáp án chính xác (A, B, C hoặc D) dùng để chấm điểm tự động.'},
      {'tag': '[EXPLANATION]', 'name': 'Thẻ Giải thích', 'desc': 'Giải thích chi tiết ngữ pháp, từ vựng và lý do chọn đáp án.'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.blue.shade800),
                      const SizedBox(width: 8),
                      const Text(
                        'Bảng Định nghĩa 10 Thẻ Định dạng Chuẩn (Tiêu chí 1)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B365D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bộ thẻ được thiết kế để phần mềm đọc tự động (Parser) phân tách chính xác cấu trúc bài thi TOEIC Reading 100 câu:',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const Divider(height: 24),
                  ...tags.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B365D),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t['tag']!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    t['desc']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card hiển thị một đề thi ở giao diện Admin
  Widget _buildAdminExamCard(ExamSummary exam) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: #${exam.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              exam.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365D),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(Icons.format_list_numbered,
                    '${exam.totalQuestions} câu hỏi'),
                const SizedBox(width: 8),
                _buildChip(Icons.timer, '${exam.durationMinutes} phút'),
                const SizedBox(width: 8),
                _buildChip(Icons.layers, 'Part 5-6-7'),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _previewExam(exam.id),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Xem trước (Preview)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B365D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _testTakeExam(exam.id),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Thi thử'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card hiển thị một lượt nộp bài của sinh viên
  Widget _buildAttemptCard(SubmitExamResultData att) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1B365D),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${att.score}',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    '/495',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        att.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          att.studentCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Đúng: ${att.totalCorrect}/100',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Sai: ${att.totalIncorrect}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Bỏ qua: ${att.totalSkipped}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Thời gian: ${att.submitTime.toLocal().toString().substring(0, 19)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Đã nộp',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String subText,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subText,
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Xem trước đề thi dạng Modal
  Future<void> _previewExam(int examId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await ApiService.getExamDetail(examId);
      if (!mounted) return;
      Navigator.pop(context); // đóng loading

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1E36),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Xem trước: ${detail.title} (100 câu)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final questions = detail.getAllQuestions();
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: questions.length,
                      itemBuilder: (context, idx) {
                        final q = questions[idx];
                        return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B365D),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Câu ${q.questionNumber}',
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
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Đáp án đúng: (${q.correctOption})',
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (q.passageText != null &&
                                q.passageText!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  q.passageText!,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black87),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              q.questionText.isNotEmpty
                                  ? q.questionText
                                  : 'Chọn đáp án điền vào chỗ trống:',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            ...q.options.map((opt) => Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '(${opt.optionLabel}) ${opt.optionText} ${opt.isCorrect ? "✓ (Đúng)" : ""}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: opt.isCorrect
                                          ? Colors.green.shade800
                                          : Colors.black87,
                                      fontWeight: opt.isCorrect
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi nạp đề thi: $e')),
    );
  }
}

  // Thi thử đề thi
  Future<void> _testTakeExam(int examId) async {
    final provider = Provider.of<ExamProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await ApiService.getExamDetail(examId);
      if (!mounted) return;
      provider.startExam(
          detail, 'Dương Hoàng Thái (Giảng viên test)', '2380602012');
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExamScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể bắt đầu thi: $e')),
      );
    }
  }
}
