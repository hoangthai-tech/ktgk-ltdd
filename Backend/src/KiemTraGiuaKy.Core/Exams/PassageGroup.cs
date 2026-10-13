using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace KiemTraGiuaKy.Exams
{
    [Table("AppPassageGroups")]
    public class PassageGroup : Entity<int>
    {
        public int ExamPartId { get; set; }

        [ForeignKey("ExamPartId")]
        public virtual ExamPart ExamPart { get; set; }

        [Required]
        [StringLength(50)]
        public string GroupCode { get; set; } // vd: "131-134", "147-148"

        [StringLength(250)]
        public string GroupTitle { get; set; }

        [Required]
        public string PassageText { get; set; }

        [StringLength(500)]
        public string ImageUrl { get; set; }

        public int OrderIndex { get; set; }

        public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
    }
}
