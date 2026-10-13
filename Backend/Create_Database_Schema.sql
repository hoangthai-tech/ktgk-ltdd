-- =========================================================================
-- HỆ THỐNG THI TOEIC READING - SCRIPT TẠO CƠ SỞ DỮ LIỆU MICROSOFT SQL SERVER
-- Sinh viên: Dương Hoàng Thái | MSSV: 2380602012 | Lớp: 23DTHC7
-- =========================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'KiemTraGiuaKyDb')
BEGIN
    CREATE DATABASE [KiemTraGiuaKyDb];
    PRINT 'Đã tạo cơ sở dữ liệu KiemTraGiuaKyDb thành công.';
END
GO

USE [KiemTraGiuaKyDb];
GO

-- 1. XÓA CÁC BẢNG NẾU ĐÃ TỒN TẠI (THEO THỨ TỰ RÀNG BUỘC KHÓA NGOẠI)
IF OBJECT_ID(N'dbo.AppStudentAnswers', N'U') IS NOT NULL DROP TABLE dbo.AppStudentAnswers;
IF OBJECT_ID(N'dbo.AppExamAttempts', N'U') IS NOT NULL DROP TABLE dbo.AppExamAttempts;
IF OBJECT_ID(N'dbo.AppAnswerOptions', N'U') IS NOT NULL DROP TABLE dbo.AppAnswerOptions;
IF OBJECT_ID(N'dbo.AppQuestions', N'U') IS NOT NULL DROP TABLE dbo.AppQuestions;
IF OBJECT_ID(N'dbo.AppPassageGroups', N'U') IS NOT NULL DROP TABLE dbo.AppPassageGroups;
IF OBJECT_ID(N'dbo.AppExamParts', N'U') IS NOT NULL DROP TABLE dbo.AppExamParts;
IF OBJECT_ID(N'dbo.AppExams', N'U') IS NOT NULL DROP TABLE dbo.AppExams;
GO

-- =========================================================================
-- 2. BẢNG AppExams (ĐỀ THI)
-- =========================================================================
CREATE TABLE dbo.AppExams (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(250) NOT NULL,
    Code NVARCHAR(50) NULL,
    DurationMinutes INT NOT NULL DEFAULT 75,
    TotalQuestions INT NOT NULL DEFAULT 100,
    Description NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreationTime DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- =========================================================================
-- 3. BẢNG AppExamParts (PHÂN VÙNG PART 5, 6, 7)
-- =========================================================================
CREATE TABLE dbo.AppExamParts (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ExamId INT NOT NULL,
    PartNumber INT NOT NULL, -- 5, 6, hoặc 7
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    TotalQuestions INT NOT NULL,
    CONSTRAINT FK_ExamParts_Exams FOREIGN KEY (ExamId) REFERENCES dbo.AppExams(Id) ON DELETE CASCADE
);
GO

-- =========================================================================
-- 4. BẢNG AppPassageGroups (NHÓM BÀI ĐỌC - GIẢI QUYẾT BÀI TOÁN PART 6 & PART 7)
-- =========================================================================
CREATE TABLE dbo.AppPassageGroups (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ExamPartId INT NOT NULL,
    GroupCode NVARCHAR(50) NOT NULL, -- VD: '131-134', '147-148', '196-200'
    GroupTitle NVARCHAR(250) NULL,
    PassageText NVARCHAR(MAX) NOT NULL,
    ImageUrl NVARCHAR(500) NULL,
    OrderIndex INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_PassageGroups_ExamParts FOREIGN KEY (ExamPartId) REFERENCES dbo.AppExamParts(Id) ON DELETE CASCADE
);
GO

-- =========================================================================
-- 5. BẢNG AppQuestions (CÂU HỎI TRẮC NGHIỆM)
-- Level 1 (Part 5): PassageGroupId là NULL
-- Level 2 (Part 6 & 7): PassageGroupId trỏ đến AppPassageGroups
-- =========================================================================
CREATE TABLE dbo.AppQuestions (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ExamId INT NOT NULL,
    ExamPartId INT NOT NULL,
    PassageGroupId INT NULL, -- NULL nếu là Part 5, có giá trị nếu là Part 6 & 7
    QuestionNumber INT NOT NULL, -- Từ 101 đến 200
    QuestionText NVARCHAR(MAX) NULL, -- Nội dung câu hỏi
    CorrectOption CHAR(1) NOT NULL, -- 'A', 'B', 'C', hoặc 'D'
    OrderIndex INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Questions_Exams FOREIGN KEY (ExamId) REFERENCES dbo.AppExams(Id),
    CONSTRAINT FK_Questions_ExamParts FOREIGN KEY (ExamPartId) REFERENCES dbo.AppExamParts(Id),
    CONSTRAINT FK_Questions_PassageGroups FOREIGN KEY (PassageGroupId) REFERENCES dbo.AppPassageGroups(Id) ON DELETE SET NULL
);
GO

-- =========================================================================
-- 6. BẢNG AppAnswerOptions (CÁC PHƯƠNG ÁN LỰA CHỌN A, B, C, D)
-- =========================================================================
CREATE TABLE dbo.AppAnswerOptions (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    QuestionId INT NOT NULL,
    OptionLabel CHAR(1) NOT NULL, -- 'A', 'B', 'C', 'D'
    OptionText NVARCHAR(MAX) NOT NULL,
    IsCorrect BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_AnswerOptions_Questions FOREIGN KEY (QuestionId) REFERENCES dbo.AppQuestions(Id) ON DELETE CASCADE
);
GO

-- =========================================================================
-- 7. BẢNG AppExamAttempts (LƯỢT LÀM BÀI CỦA THÍ SINH)
-- Quản lý thời gian 75 phút, tự động thu bài, khóa chọn đáp án khi hết giờ
-- =========================================================================
CREATE TABLE dbo.AppExamAttempts (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ExamId INT NOT NULL,
    StudentName NVARCHAR(150) NOT NULL,
    StudentCode NVARCHAR(50) NOT NULL,
    StartTime DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    SubmitTime DATETIME2 NULL,
    Score INT NULL,
    TotalCorrect INT NULL DEFAULT 0,
    TotalIncorrect INT NULL DEFAULT 0,
    TotalSkipped INT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'InProgress', -- 'InProgress', 'Submitted', 'TimeOut'
    CONSTRAINT FK_ExamAttempts_Exams FOREIGN KEY (ExamId) REFERENCES dbo.AppExams(Id)
);
GO

-- =========================================================================
-- 8. BẢNG AppStudentAnswers (LƯU VẾT CÂU TRẢ LỜI CỦA THÍ SINH)
-- Lưu tạm câu trả lời, cho phép đổi/hủy lựa chọn trước khi nộp
-- =========================================================================
CREATE TABLE dbo.AppStudentAnswers (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    AttemptId INT NOT NULL,
    QuestionId INT NOT NULL,
    SelectedOption CHAR(1) NULL, -- 'A', 'B', 'C', 'D' hoặc NULL nếu hủy chọn
    IsCorrect BIT NULL, -- Tính tự động khi nộp bài
    AnsweredTime DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_StudentAnswers_Attempts FOREIGN KEY (AttemptId) REFERENCES dbo.AppExamAttempts(Id) ON DELETE CASCADE,
    CONSTRAINT FK_StudentAnswers_Questions FOREIGN KEY (QuestionId) REFERENCES dbo.AppQuestions(Id)
);
GO

-- =========================================================================
-- 9. TẠO INDEXES ĐỂ TỐI ƯU HIỆU NĂNG TRUY VẤN
-- =========================================================================
CREATE INDEX IX_Questions_ExamId_QuestionNumber ON dbo.AppQuestions(ExamId, QuestionNumber);
CREATE INDEX IX_Questions_PassageGroupId ON dbo.AppQuestions(PassageGroupId);
CREATE INDEX IX_AnswerOptions_QuestionId ON dbo.AppAnswerOptions(QuestionId);
CREATE INDEX IX_ExamAttempts_StudentCode ON dbo.AppExamAttempts(StudentCode);
CREATE INDEX IX_StudentAnswers_AttemptId_QuestionId ON dbo.AppStudentAnswers(AttemptId, QuestionId);
GO

PRINT 'Tạo toàn bộ cấu trúc CSDL thành công 100%!';
GO
