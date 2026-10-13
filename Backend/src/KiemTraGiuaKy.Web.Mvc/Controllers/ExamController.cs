using System;
using System.IO;
using System.Threading.Tasks;
using Abp.AspNetCore.Mvc.Authorization;
using KiemTraGiuaKy.Controllers;
using KiemTraGiuaKy.Exams;
using KiemTraGiuaKy.Exams.Dto;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KiemTraGiuaKy.Web.Controllers
{
    public class ExamController : KiemTraGiuaKyControllerBase
    {
        private readonly IExamAppService _examAppService;

        public ExamController(IExamAppService examAppService)
        {
            _examAppService = examAppService;
        }

        // 1. Danh sách đề thi
        public async Task<IActionResult> Index()
        {
            var exams = await _examAppService.GetAllExamsAsync();
            return View(exams);
        }

        // 2. Giao diện Upload đề thi từ file Word (.docx)
        [HttpGet]
        public IActionResult Upload()
        {
            return View();
        }

        // 2. Xử lý Upload & Validate file Word
        [HttpPost]
        [IgnoreAntiforgeryToken]
        public async Task<IActionResult> Upload(IFormFile docxFile)
        {
            if (docxFile == null || docxFile.Length == 0)
            {
                ViewBag.ErrorMessage = "Vui lòng chọn một file Word định dạng .docx để tải lên.";
                return View();
            }

            var extension = Path.GetExtension(docxFile.FileName).ToLowerInvariant();
            if (extension != ".docx")
            {
                ViewBag.ErrorMessage = "Hệ thống chỉ chấp nhận file tài liệu định dạng Microsoft Word (.docx).";
                return View();
            }

            using (var stream = docxFile.OpenReadStream())
            {
                var result = await _examAppService.ImportFromDocxStreamAsync(stream);
                if (!result.Success)
                {
                    ViewBag.Errors = result.Errors;
                    ViewBag.ErrorMessage = $"Tệp tin '{docxFile.FileName}' bị phát hiện sai định dạng chuẩn! Hệ thống đã hủy bỏ toàn bộ và không lưu vào CSDL.";
                    return View();
                }

                TempData["SuccessMessage"] = $"Tải lên và import đề thi thành công! Đã tạo đề thi '{result.ExamTitle}' với đủ {result.TotalQuestionsImported} câu hỏi chuẩn 100%.";
                return RedirectToAction("Preview", new { id = result.ExamId });
            }
        }

        // 3. Xem trước đề thi (Preview) để rà soát lỗi chính tả & hình ảnh
        public async Task<IActionResult> Preview(int id)
        {
            var exam = await _examAppService.GetExamDetailAsync(id);
            if (exam == null)
            {
                return NotFound("Không tìm thấy đề thi yêu cầu.");
            }
            return View(exam);
        }

        // 4. Chỉnh sửa nội dung đề thi sau khi import
        public async Task<IActionResult> Edit(int id)
        {
            var exam = await _examAppService.GetExamDetailAsync(id);
            if (exam == null)
            {
                return NotFound("Không tìm thấy đề thi yêu cầu.");
            }
            return View(exam);
        }

        // 5. AJAX Cập nhật câu hỏi
        [HttpPost]
        [IgnoreAntiforgeryToken]
        public async Task<IActionResult> UpdateQuestion([FromBody] UpdateQuestionInput input)
        {
            var success = await _examAppService.UpdateQuestionAsync(input);
            return Json(new { success });
        }

        // 6. AJAX Cập nhật đoạn văn bài đọc
        [HttpPost]
        [IgnoreAntiforgeryToken]
        public async Task<IActionResult> UpdatePassage([FromBody] UpdatePassageInput input)
        {
            var success = await _examAppService.UpdatePassageAsync(input);
            return Json(new { success });
        }

        // 7. Xóa đề thi
        [HttpPost]
        [IgnoreAntiforgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            await _examAppService.DeleteExamAsync(id);
            TempData["SuccessMessage"] = "Đã xóa đề thi thành công.";
            return RedirectToAction("Index");
        }
    }
}
