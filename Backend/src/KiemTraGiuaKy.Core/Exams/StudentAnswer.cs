using System;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppStudentAnswers")]
    public class StudentAnswer : Entity<int>
    {
        public int AttemptId { get; set; }

        [ForeignKey("AttemptId")]
        public virtual ExamAttempt Attempt { get; set; }

        public int QuestionId { get; set; }

        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; }

        public char? SelectedOption { get; set; } // 'A', 'B', 'C', 'D' hoặc NULL

        public bool? IsCorrect { get; set; }

        public DateTime AnsweredTime { get; set; } = DateTime.UtcNow;
    }
}
