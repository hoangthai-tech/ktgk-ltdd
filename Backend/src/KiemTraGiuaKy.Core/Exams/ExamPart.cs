using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppExamParts")]
    public class ExamPart : Entity<int>
    {
        public int ExamId { get; set; }

        [ForeignKey("ExamId")]
        public virtual Exam Exam { get; set; }

        public int PartNumber { get; set; } // 5, 6, 7

        [Required]
        [StringLength(100)]
        public string Name { get; set; }

        public string Description { get; set; }

        public int TotalQuestions { get; set; }

        public virtual ICollection<PassageGroup> PassageGroups { get; set; } = new List<PassageGroup>();
        public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
    }
}
