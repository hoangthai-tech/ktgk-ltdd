using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppQuestions")]
    public class Question : Entity<int>
    {
        public int ExamId { get; set; }

        [ForeignKey("ExamId")]
        public virtual Exam Exam { get; set; }

        public int ExamPartId { get; set; }

        [ForeignKey("ExamPartId")]
        public virtual ExamPart ExamPart { get; set; }

        public int? PassageGroupId { get; set; }

        [ForeignKey("PassageGroupId")]
        public virtual PassageGroup PassageGroup { get; set; }

        public int QuestionNumber { get; set; } // 101 -> 200

        public string QuestionText { get; set; }

        public char CorrectOption { get; set; } // 'A', 'B', 'C', 'D'

        public int OrderIndex { get; set; }

        public virtual ICollection<AnswerOption> Options { get; set; } = new List<AnswerOption>();
    }
}
