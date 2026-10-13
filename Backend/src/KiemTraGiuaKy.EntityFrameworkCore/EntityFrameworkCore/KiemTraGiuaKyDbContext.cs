using Abp.Zero.EntityFrameworkCore;
using KiemTraGiuaKy.Authorization.Roles;
using KiemTraGiuaKy.Authorization.Users;
using KiemTraGiuaKy.MultiTenancy;
using Microsoft.EntityFrameworkCore;

namespace KiemTraGiuaKy.EntityFrameworkCore;

public class KiemTraGiuaKyDbContext : AbpZeroDbContext<Tenant, Role, User, KiemTraGiuaKyDbContext>
{
    /* Define a DbSet for each entity of the application */
    public virtual DbSet<KiemTraGiuaKy.Exams.Exam> Exams { get; set; }
    public virtual DbSet<KiemTraGiuaKy.Exams.ExamPart> ExamParts { get; set; }
    public virtual DbSet<KiemTraGiuaKy.Exams.PassageGroup> PassageGroups { get; set; }
    public virtual DbSet<KiemTraGiuaKy.Exams.Question> Questions { get; set; }
    public virtual DbSet<KiemTraGiuaKy.Exams.AnswerOption> AnswerOptions { get; set; }
    public virtual DbSet<KiemTraGiuaKy.Exams.ExamAttempt> ExamAttempts { get; set; }
    public virtual DbSet<KiemTraGiuaKy.Exams.StudentAnswer> StudentAnswers { get; set; }

    public KiemTraGiuaKyDbContext(DbContextOptions<KiemTraGiuaKyDbContext> options)
        : base(options)
    {
    }
}
