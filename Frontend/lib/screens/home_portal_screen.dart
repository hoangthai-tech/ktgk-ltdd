import 'package:flutter/material.dart';
import 'exam_list_screen.dart';
import 'admin_dashboard_screen.dart';

class HomePortalScreen extends StatelessWidget {
  const HomePortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Logo & Header Brand
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B365D),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'HỆ THỐNG THI TOEIC READING',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B365D),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Phân tích & Xây dựng Ứng dụng Di động Kiểm tra Giữa kỳ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Card Thông tin Sinh viên thực hiện
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B365D), Color(0xFF0066CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.badge_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sinh viên thực hiện:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'Dương Hoàng Thái',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'MSSV: 2380602012  •  Lớp: 23DTHC7',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Đề thi: Reading v02 (ETS TOEIC 2019 Test 2)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Row(
                children: [
                  Icon(Icons.hub_outlined, color: Color(0xFF1B365D), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'CHỌN PHÂN HỆ TRUY CẬP HỆ THỐNG',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B365D),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ==========================================
              // 1. CỔNG DÀNH CHO HỌC SINH (STUDENT PORTAL)
              // ==========================================
              _buildRoleCard(
                context: context,
                icon: Icons.school_outlined,
                badgeText: 'DÀNH CHO HỌC SINH',
                badgeColor: const Color(0xFF0066CC),
                title: 'CỔNG THI SINH VIÊN',
                description:
                    'Dành cho người học: Xem danh sách đề thi, làm bài thi 100 câu (Part 5, 6, 7), đồng hồ đếm ngược 75 phút, Question Palette thông minh, nộp bài & nhận bảng điểm chi tiết.',
                buttonText: 'VÀO PHÒNG THI SINH VIÊN',
                buttonColor: const Color(0xFF0066CC),
                features: const [
                  'Làm bài thi trắc nghiệm 100 câu',
                  'Đếm ngược 75:00 & Tự động nộp bài',
                  'Question Palette 100 câu linh hoạt',
                  'Chấm điểm TOEIC 495 & Rà soát đáp án',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExamListScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ========================================================
              // 2. CỔNG DÀNH CHO GIẢNG VIÊN / QUẢN TRỊ VIÊN (ADMIN PORTAL)
              // ========================================================
              _buildRoleCard(
                context: context,
                icon: Icons.admin_panel_settings_outlined,
                badgeText: 'DÀNH CHO GIẢNG VIÊN & ADMIN',
                badgeColor: const Color(0xFF0F1E36),
                title: 'CỔNG QUẢN TRỊ ADMIN',
                description:
                    'Dành cho Giảng viên & Quản trị viên: Quản lý ngân hàng đề thi CSDL, xem trước (Preview) cấu trúc 100 câu, theo dõi bảng điểm và lịch sử nộp bài của sinh viên, xem quy chuẩn thẻ tags.',
                buttonText: 'VÀO KHU VỰC QUẢN TRỊ ADMIN',
                buttonColor: const Color(0xFF0F1E36),
                features: const [
                  'Quản lý danh sách đề thi CSDL SQL Server',
                  'Xem trước cấu trúc 100 câu chia Part 5-6-7',
                  'Bảng điểm & Lịch sử nộp bài của học sinh',
                  'Bảng định nghĩa 10 thẻ Tags quy chuẩn',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Thông tin chân trang
              Center(
                child: Text(
                  'Hệ thống Backend: ASP.NET Boilerplate MVC (http://localhost:5000)\nHệ thống Frontend: Flutter Mobile App (Material 3)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: badgeColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(icon, color: badgeColor, size: 28),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 16),
              ...features.map((feat) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
