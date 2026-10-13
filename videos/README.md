# VIDEO DEMO DỰ ÁN THI TOEIC READING

- **Sinh viên thực hiện**: Dương Hoàng Thái
- **Mã số sinh viên (MSSV)**: 2380602012
- **Lớp**: 23DTHC7
- **Mã đề thi**: Reading v02 (ETS TOEIC 2019 Practice Test 2 - 100 câu hỏi Reading)

---

## 1. Thông tin Video Demo
- **File video đính kèm**: `Quản lý Đề thi TOEIC Reading _ KiemTraGiuaKy - Google Chrome 2026-10-13 19-31-25.mp4`
- **Thời lượng**: Full screen toàn bộ các tính năng theo yêu cầu đề bài.

## 2. Các chức năng được trình diễn trong Video:
1. **Phần 1: Website Quản trị Admin Backend (ASP.NET Boilerplate MVC - `http://localhost:5000/Exam`)**:
   - Upload file đề thi Word `TOEIC_Reading_v02.docx` chứa 10 bộ thẻ Tags chuẩn.
   - Kiểm tra cơ chế tự động validate và thông báo thành công bóc tách 100 câu hỏi (Part 5, 6, 7).
   - Xem trước cấu trúc đề thi trực quan (Preview).
   - Chỉnh sửa câu hỏi, đáp án và nội dung đoạn văn bài đọc (Edit).

2. **Phần 2: Ứng dụng Di động Mobile App (Flutter - `http://localhost:8080/`)**:
   - Cổng chọn vai trò (Học sinh vs Quản trị viên Admin).
   - Nhập thông tin thí sinh: Họ và tên (`Dương Hoàng Thái`), MSSV (`2380602012`), Lớp học (`23DTHC7`).
   - Giao diện làm bài 100 câu: đồng hồ đếm ngược 75 phút, chọn đáp án Part 5/6/7.
   - Bảng chọn câu hỏi **Question Palette** 100 câu phân màu trạng thái (Đã làm / Chưa làm).
   - Nộp bài thi có cảnh báo kiểm tra số câu chưa hoàn thành.
   - Màn hình kết quả: Chấm điểm tự động quy đổi thang 495 ETS, thống kê Đúng/Sai/Bỏ qua, rà soát chi tiết 100 đáp án.
   - Bảng điểm thí sinh được đồng bộ realtime về Admin Dashboard từ REST API.
