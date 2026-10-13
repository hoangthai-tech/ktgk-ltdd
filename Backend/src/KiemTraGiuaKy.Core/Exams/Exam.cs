using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppExams")]
    public class Exam : Entity<int>
    {
        [Required]
        [StringLength(250)]
        public string Title { get; set; }

        [StringLength(50)]
        public string Code { get; set; }

        public int DurationMinutes { get; set; } = 75;

        public int TotalQuestions { get; set; } = 100;

        public string Description { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreationTime { get; set; } = DateTime.UtcNow;

        public virtual ICollection<ExamPart> Parts { get; set; } = new List<ExamPart>();
        public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
        public virtual ICollection<ExamAttempt> Attempts { get; set; } = new List<ExamAttempt>();
    }
}
