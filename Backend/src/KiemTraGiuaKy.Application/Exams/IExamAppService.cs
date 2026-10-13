using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Abp.Application.Services;
using KiemTraGiuaKy.Exams.Dto;

namespace KiemTraGiuaKy.Exams
{
    public interface IExamAppService : IApplicationService
    {
        Task<ImportDocxResult> ImportFromDocxStreamAsync(Stream docxStream);
        Task<List<ExamDto>> GetAllExamsAsync();
        Task<ExamDetailDto> GetExamDetailAsync(int examId);
        Task<bool> UpdateQuestionAsync(UpdateQuestionInput input);
        Task<bool> UpdatePassageAsync(UpdatePassageInput input);
        Task<SubmitExamResult> SubmitExamAsync(SubmitExamInput input);
        Task<List<SubmitExamResult>> GetExamAttemptsAsync();
        Task<bool> DeleteExamAsync(int examId);
    }
}
