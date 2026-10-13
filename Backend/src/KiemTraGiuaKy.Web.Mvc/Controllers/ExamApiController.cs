using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.Web.Models;
using KiemTraGiuaKy.Controllers;
using KiemTraGiuaKy.Exams;
using KiemTraGiuaKy.Exams.Dto;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;

namespace KiemTraGiuaKy.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [EnableCors]
    [IgnoreAntiforgeryToken]
    [DontWrapResult]
    public class ExamApiController : KiemTraGiuaKyControllerBase
    {
        private readonly IExamAppService _examAppService;

        public ExamApiController(IExamAppService examAppService)
        {
            _examAppService = examAppService;
        }

        // GET: api/examapi/list - Danh sách đề thi cho thí sinh chọn
        [HttpGet("list")]
        public async Task<ActionResult<List<ExamDto>>> GetExamList()
        {
            var exams = await _examAppService.GetAllExamsAsync();
            return Ok(exams);
        }

        // GET: api/examapi/{id} - Chi tiết đề thi bao gồm 100 câu hỏi và các bài đọc
        [HttpGet("{id}")]
        public async Task<ActionResult<ExamDetailDto>> GetExamDetail(int id)
        {
            var exam = await _examAppService.GetExamDetailAsync(id);
            if (exam == null)
            {
                return NotFound(new { message = "Không tìm thấy đề thi." });
            }
            return Ok(exam);
        }

        // POST: api/examapi/submit - Nộp bài và chấm điểm tự động
        [HttpPost("submit")]
        public async Task<ActionResult<SubmitExamResult>> SubmitExam([FromBody] SubmitExamInput input)
        {
            if (input == null || input.ExamId <= 0)
            {
                return BadRequest(new { message = "Dữ liệu nộp bài không hợp lệ." });
            }

            var result = await _examAppService.SubmitExamAsync(input);
            return Ok(result);
        }

        // GET: api/examapi/attempts - Danh sách kết quả thi của học sinh cho Giảng viên / Admin
        [HttpGet("attempts")]
        public async Task<ActionResult<List<SubmitExamResult>>> GetAttempts()
        {
            var attempts = await _examAppService.GetExamAttemptsAsync();
            return Ok(attempts);
        }

        // DELETE: api/examapi/{id} - Xóa đề thi (dành cho Admin)
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteExam(int id)
        {
            var success = await _examAppService.DeleteExamAsync(id);
            return Ok(new { success });
        }

        // PUT: api/examapi/question - Cập nhật câu hỏi (dành cho Admin)
        [HttpPut("question")]
        public async Task<ActionResult> UpdateQuestion([FromBody] UpdateQuestionInput input)
        {
            var success = await _examAppService.UpdateQuestionAsync(input);
            return Ok(new { success });
        }
    }
}
