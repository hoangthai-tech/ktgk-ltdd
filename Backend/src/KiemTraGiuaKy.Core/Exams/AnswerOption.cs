using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppAnswerOptions")]
    public class AnswerOption : Entity<int>
    {
        public int QuestionId { get; set; }

        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; }

        public char OptionLabel { get; set; } // 'A', 'B', 'C', 'D'

        [Required]
        public string OptionText { get; set; }

        public bool IsCorrect { get; set; }
    }
}
