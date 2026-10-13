# BÀI THI GIỮA KỲ LẬP TRÌNH DI ĐỘNG
## ĐỀ TÀI: PHÂN TÍCH VÀ XÂY DỰNG ỨNG DỤNG THI TOEIC READING

- **Họ và tên sinh viên**: Dương Hoàng Thái
- **Mã số sinh viên (MSSV)**: 2380602012
- **Lớp**: 23DTHC7
- **Mã đề thi**: Reading v02 (ETS TOEIC 2019 Practice Test 2 - 100 câu hỏi Reading)
- **Figma Design Link**: https://www.figma.com/design/NsIXAMdRz5G54RCgYcxSg8/TOEIC-Reading-App---DuongHoangThai---2380602012
- **GitHub Repository**: https://github.com/hoangthai-tech/ktgk-ltdd

---

## 1. Cấu trúc Dự án
Dự án được tổ chức theo đúng quy chuẩn yêu cầu của giảng viên:
```
KTGK LTDD/
├── Backend/                                  # Mã nguồn Website Quản trị Admin & REST API
│   ├── src/
│   │   ├── KiemTraGiuaKy.Core/               # Thực thể CSDL (Domain Entities: Exam, Question, Option,...)
│   │   ├── KiemTraGiuaKy.EntityFrameworkCore/# EF Core DbContext, Migrations SQL Server
│   │   ├── KiemTraGiuaKy.Application/        # Nghiệp vụ bóc tách Docx, Validate 100%, Chấm điểm TOEIC
│   │   ├── KiemTraGiuaKy.Web.Mvc/            # Giao diện MVC Admin (Upload, Edit, Preview) & REST API
│   └── KiemTraGiuaKy.sln
├── Frontend/                                 # Mã nguồn Ứng dụng Di động Mobile App (Flutter)
│   ├── lib/
│   │   ├── models/                           # Mô hình dữ liệu đề thi, câu hỏi, kết quả
│   │   ├── providers/                        # Quản lý trạng thái làm bài, Timer 75p, Palette
│   │   ├── screens/                          # Các phân hệ giao diện:
│   │   │   ├── home_portal_screen.dart       # Cổng Phân quyền tách biệt Học sinh và Quản trị Admin
│   │   │   ├── exam_list_screen.dart         # Phân hệ Học sinh: Danh sách đề thi & Nhập thông tin
│   │   │   ├── exam_screen.dart              # Phân hệ Học sinh: Làm bài 100 câu, Timer 75p, Palette
│   │   │   ├── result_screen.dart            # Phân hệ Học sinh: Bảng điểm 495 & Rà soát 100 câu
│   │   │   └── admin_dashboard_screen.dart   # Phân hệ Admin: Quản lý ngân hàng đề, Bảng điểm sinh viên
│   │   ├── services/                         # Kết nối REST API backend
│   │   └── main.dart
│   └── pubspec.yaml
├── videos/                                   # Thư mục chứa video demo full screen dự án
│   └── README.md
├── Create_Database_Schema.sql                # File mã nguồn tạo CSDL SQL Server KiemTraGiuaKyDb
├── TOEIC_Reading_v02.docx                    # File đề thi 100 câu đã định dạng đầy đủ Tags
├── TOEIC_Reading_v02_TagDefinitions.docx      # File đề thi kèm Bảng quy chuẩn 10 thẻ Tags
├── BaoCao-DuongHoangThai-2380602012_Final.docx # Báo cáo hoàn chỉnh nộp bài (Đầy đủ 14 hình ảnh & đánh giá)
├── database_diagram.png                      # Sơ đồ CSDL Thực thể Liên kết (ERD)
├── figma_full_system_mockup.png              # Bản vẽ thiết kế UI/UX trên Figma (7 Frames Học sinh & Admin)
└── README.md
```

---

## 2. Bảng Tiêu Chí Đánh Giá Hoàn Thành (10.0 / 10.0 Điểm)

| No | Yêu cầu / Chức năng thực hiện | Điểm tối đa | Điểm tự đánh giá | Minh chứng & Trạng thái |
|:--:|:------------------------------|:-----------:|:----------------:|:------------------------|
| 1 | File WORD TOEIC có định nghĩa bộ thẻ tags chuẩn | 1.0 | 1.0 | `TOEIC_Reading_v02.docx` (100 câu Part 5, 6, 7 + Bảng 10 thẻ) |
| 2 | Phân tích và thiết kế CSDL quan hệ phù hợp | 1.0 | 1.0 | CSDL SQL Server `KiemTraGiuaKyDb`, phân cấp Level 1 & 2 triệt để |
| 3 | Chức năng Upload file Word, kiểm tra hợp lệ 100% | 1.0 | 1.0 | Backend MVC bóc tách OpenXML, Validate nghiêm ngặt, Rollback an toàn |
| 4 | Chức năng cập nhật, chỉnh sửa nội dung đề thi | 1.0 | 1.0 | Giao diện Admin rà soát, chỉnh sửa trực quan câu hỏi & bài đọc qua AJAX |
| 5 | Chức năng hiển thị danh sách đề thi cho users | 1.0 | 1.0 | Mobile Flutter hiển thị danh sách realtime từ REST API |
| 6 | Chức năng thi 100 câu + Link thiết kế Figma | 3.0 | 3.0 | Đếm ngược 75 phút, tự động thu bài, Question Palette 100 câu, bản vẽ Figma |
| 7 | Chức năng hiển thị kết quả thi & chấm tự động | 1.0 | 1.0 | Chấm điểm tự động, thang điểm ETS 495, xem lại chi tiết 100 câu |
| 8 | Giao diện đẹp, hiện đại, thân thiện người dùng | 1.0 | 1.0 | Chuẩn Material 3, phối màu Navy/Blue sang trọng, responsive mượt mà |
| **Tổng** | **Tổng kết dự án** | **10.0** | **10.0** | **HOÀN THÀNH 100% TẤT CẢ TIÊU CHÍ** |

---

## 3. Hướng Dẫn Khởi Chạy Dự Án

### Yêu cầu môi trường:
- .NET 9.0 SDK
- Microsoft SQL Server (LocalDB hoặc SQL Server Express/Developer)
- Flutter SDK (3.x trở lên)
- Trình duyệt Web (Chrome/Edge) hoặc Thiết bị di động / Máy ảo Android Emulator

### Bước 1: Khởi động Backend (ASP.NET Boilerplate MVC & REST API)
1. Mở PowerShell hoặc Terminal tại thư mục `Backend/src/KiemTraGiuaKy.Web.Mvc`.
2. Khởi chạy ứng dụng:
   ```bash
   dotnet run --urls "http://localhost:5000"
   ```
3. Truy cập trình duyệt: `http://localhost:5000`
   - Đăng nhập Admin: `admin` / mật khẩu quản trị.
   - Quản lý đề thi: Vào menu **Quản lý Đề thi** để Upload file `TOEIC_Reading_v02.docx`, xem Preview hoặc Chỉnh sửa nội dung.

### Bước 2: Khởi động Frontend Mobile App (Flutter)
1. Mở PowerShell hoặc Terminal tại thư mục `Frontend`.
2. Khởi chạy ứng dụng:
   ```bash
   # Chạy trên nền tảng Web:
   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

   # Hoặc chạy trên Android Emulator:
   flutter run -d android
   ```
3. Truy cập ứng dụng: `http://localhost:8080`
   - Thông tin thí sinh: **Dương Hoàng Thái** (MSSV: 2380602012).
   - Chọn đề **TOEIC Reading Practice Test 02** và nhấn **BẮT ĐẦU LÀM BÀI THI**.
   - Làm bài với đồng hồ 75 phút, chọn câu hỏi, mở Question Palette và Nộp bài.
   - Xem kết quả điểm số và rà soát đáp án chi tiết.
