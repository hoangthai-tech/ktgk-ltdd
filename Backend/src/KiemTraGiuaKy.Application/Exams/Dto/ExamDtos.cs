using System;
using System.Collections.Generic;

namespace KiemTraGiuaKy.Exams.Dto
{
    public class ExamDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Code { get; set; }
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreationTime { get; set; }
    }

    public class ExamDetailDto : ExamDto
    {
        public List<ExamPartDto> Parts { get; set; } = new List<ExamPartDto>();
    }

    public class ExamPartDto
    {
        public int Id { get; set; }
        public int PartNumber { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int TotalQuestions { get; set; }
        public List<PassageGroupDto> Groups { get; set; } = new List<PassageGroupDto>();
        public List<QuestionDto> IndependentQuestions { get; set; } = new List<QuestionDto>();
    }

    public class PassageGroupDto
    {
        public int Id { get; set; }
        public string GroupCode { get; set; }
        public string GroupTitle { get; set; }
        public string PassageText { get; set; }
        public string ImageUrl { get; set; }
        public int OrderIndex { get; set; }
        public List<QuestionDto> Questions { get; set; } = new List<QuestionDto>();
    }

    public class QuestionDto
    {
        public int Id { get; set; }
        public int QuestionNumber { get; set; }
        public string QuestionText { get; set; }
        public char CorrectOption { get; set; }
        public int? PassageGroupId { get; set; }
        public List<AnswerOptionDto> Options { get; set; } = new List<AnswerOptionDto>();
    }

    public class AnswerOptionDto
    {
        public int Id { get; set; }
        public char OptionLabel { get; set; }
        public string OptionText { get; set; }
        public bool IsCorrect { get; set; }
    }

    public class UpdateQuestionInput
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }
        public char CorrectOption { get; set; }
        public string OptionA { get; set; }
        public string OptionB { get; set; }
        public string OptionC { get; set; }
        public string OptionD { get; set; }
    }

    public class UpdatePassageInput
    {
        public int PassageGroupId { get; set; }
        public string GroupTitle { get; set; }
        public string PassageText { get; set; }
        public string ImageUrl { get; set; }
    }

    public class SubmitExamInput
    {
        public int ExamId { get; set; }
        public string StudentName { get; set; }
        public string StudentCode { get; set; }
        public Dictionary<int, char?> Answers { get; set; } = new Dictionary<int, char?>(); // QuestionNumber -> Selected 'A'|'B'|'C'|'D'
    }

    public class SubmitExamResult
    {
        public int AttemptId { get; set; }
        public int ExamId { get; set; }
        public string StudentName { get; set; }
        public string StudentCode { get; set; }
        public int TotalQuestions { get; set; }
        public int TotalCorrect { get; set; }
        public int TotalIncorrect { get; set; }
        public int TotalSkipped { get; set; }
        public int Score { get; set; } // TOEIC scaled score estimate (out of 495)
        public string Status { get; set; }
        public DateTime SubmitTime { get; set; }
    }

    public class ImportDocxResult
    {
        public bool Success { get; set; }
        public int? ExamId { get; set; }
        public string ExamTitle { get; set; }
        public int TotalQuestionsImported { get; set; }
        public List<string> Errors { get; set; } = new List<string>();
        public List<string> Warnings { get; set; } = new List<string>();
    }
}
