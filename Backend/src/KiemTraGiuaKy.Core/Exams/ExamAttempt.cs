using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppExamAttempts")]
    public class ExamAttempt : Entity<int>
    {
        public int ExamId { get; set; }

        [ForeignKey("ExamId")]
        public virtual Exam Exam { get; set; }

        [Required]
        [StringLength(150)]
        public string StudentName { get; set; }

        [Required]
        [StringLength(50)]
        public string StudentCode { get; set; }

        public DateTime StartTime { get; set; } = DateTime.UtcNow;

        public DateTime? SubmitTime { get; set; }

        public int? Score { get; set; }

        public int TotalCorrect { get; set; } = 0;

        public int TotalIncorrect { get; set; } = 0;

        public int TotalSkipped { get; set; } = 0;

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "InProgress"; // InProgress, Submitted, TimeOut

        public virtual ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();
    }
}
