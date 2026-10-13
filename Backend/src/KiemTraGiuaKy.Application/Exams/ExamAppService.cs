using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Abp.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using KiemTraGiuaKy.Exams.Dto;

namespace KiemTraGiuaKy.Exams
{
    public class ExamAppService : KiemTraGiuaKyAppServiceBase, IExamAppService
    {
        private readonly IRepository<Exam, int> _examRepository;
        private readonly IRepository<ExamPart, int> _partRepository;
        private readonly IRepository<PassageGroup, int> _groupRepository;
        private readonly IRepository<Question, int> _questionRepository;
        private readonly IRepository<AnswerOption, int> _optionRepository;
        private readonly IRepository<ExamAttempt, int> _attemptRepository;
        private readonly IRepository<StudentAnswer, int> _studentAnswerRepository;

        public ExamAppService(
            IRepository<Exam, int> examRepository,
            IRepository<ExamPart, int> partRepository,
            IRepository<PassageGroup, int> groupRepository,
            IRepository<Question, int> questionRepository,
            IRepository<AnswerOption, int> optionRepository,
            IRepository<ExamAttempt, int> attemptRepository,
            IRepository<StudentAnswer, int> studentAnswerRepository)
        {
            _examRepository = examRepository;
            _partRepository = partRepository;
            _groupRepository = groupRepository;
            _questionRepository = questionRepository;
            _optionRepository = optionRepository;
            _attemptRepository = attemptRepository;
            _studentAnswerRepository = studentAnswerRepository;
        }

        public async Task<ImportDocxResult> ImportFromDocxStreamAsync(Stream docxStream)
        {
            var parseResult = DocxExamParser.ParseAndValidate(docxStream);
            if (!parseResult.IsValid)
            {
                return new ImportDocxResult
                {
                    Success = false,
                    Errors = parseResult.Errors,
                    Warnings = parseResult.Warnings
                };
            }

            var exam = parseResult.ParsedExam;
            int examId = await _examRepository.InsertAndGetIdAsync(exam);

            return new ImportDocxResult
            {
                Success = true,
                ExamId = examId,
                ExamTitle = exam.Title,
                TotalQuestionsImported = exam.Questions.Count,
                Warnings = parseResult.Warnings
            };
        }

        public async Task<List<ExamDto>> GetAllExamsAsync()
        {
            var exams = await _examRepository.GetAll()
                .OrderByDescending(e => e.CreationTime)
                .Select(e => new ExamDto
                {
                    Id = e.Id,
                    Title = e.Title,
                    Code = e.Code,
                    DurationMinutes = e.DurationMinutes,
                    TotalQuestions = e.TotalQuestions,
                    Description = e.Description,
                    IsActive = e.IsActive,
                    CreationTime = e.CreationTime
                }).ToListAsync();

            return exams;
        }

        public async Task<ExamDetailDto> GetExamDetailAsync(int examId)
        {
            var exam = await _examRepository.GetAll()
                .Include(e => e.Parts)
                    .ThenInclude(p => p.PassageGroups)
                .Include(e => e.Questions)
                    .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == examId);

            if (exam == null)
            {
                return null;
            }

            var dto = new ExamDetailDto
            {
                Id = exam.Id,
                Title = exam.Title,
                Code = exam.Code,
                DurationMinutes = exam.DurationMinutes,
                TotalQuestions = exam.TotalQuestions,
                Description = exam.Description,
                IsActive = exam.IsActive,
                CreationTime = exam.CreationTime
            };

            foreach (var part in exam.Parts.OrderBy(p => p.PartNumber))
            {
                var partDto = new ExamPartDto
                {
                    Id = part.Id,
                    PartNumber = part.PartNumber,
                    Name = part.Name,
                    Description = part.Description,
                    TotalQuestions = part.TotalQuestions
                };

                // Independent questions (Part 5)
                var indQuestions = exam.Questions
                    .Where(q => q.ExamPartId == part.Id && q.PassageGroupId == null)
                    .OrderBy(q => q.QuestionNumber);

                foreach (var q in indQuestions)
                {
                    partDto.IndependentQuestions.Add(MapQuestionToDto(q));
                }

                // Grouped passages (Part 6 & Part 7)
                foreach (var g in part.PassageGroups.OrderBy(g => g.OrderIndex))
                {
                    var gDto = new PassageGroupDto
                    {
                        Id = g.Id,
                        GroupCode = g.GroupCode,
                        GroupTitle = g.GroupTitle,
                        PassageText = g.PassageText,
                        ImageUrl = g.ImageUrl,
                        OrderIndex = g.OrderIndex
                    };

                    var groupQuestions = exam.Questions
                        .Where(q => q.PassageGroupId == g.Id)
                        .OrderBy(q => q.QuestionNumber);

                    foreach (var q in groupQuestions)
                    {
                        gDto.Questions.Add(MapQuestionToDto(q));
                    }

                    partDto.Groups.Add(gDto);
                }

                dto.Parts.Add(partDto);
            }

            return dto;
        }

        public async Task<bool> UpdateQuestionAsync(UpdateQuestionInput input)
        {
            var question = await _questionRepository.GetAll()
                .Include(q => q.Options)
                .FirstOrDefaultAsync(q => q.Id == input.QuestionId);

            if (question == null)
            {
                return false;
            }

            question.QuestionText = input.QuestionText;
            question.CorrectOption = input.CorrectOption;

            // Update choices A, B, C, D
            var optA = question.Options.FirstOrDefault(o => o.OptionLabel == 'A');
            if (optA != null) { optA.OptionText = input.OptionA ?? optA.OptionText; optA.IsCorrect = (input.CorrectOption == 'A'); }

            var optB = question.Options.FirstOrDefault(o => o.OptionLabel == 'B');
            if (optB != null) { optB.OptionText = input.OptionB ?? optB.OptionText; optB.IsCorrect = (input.CorrectOption == 'B'); }

            var optC = question.Options.FirstOrDefault(o => o.OptionLabel == 'C');
            if (optC != null) { optC.OptionText = input.OptionC ?? optC.OptionText; optC.IsCorrect = (input.CorrectOption == 'C'); }

            var optD = question.Options.FirstOrDefault(o => o.OptionLabel == 'D');
            if (optD != null) { optD.OptionText = input.OptionD ?? optD.OptionText; optD.IsCorrect = (input.CorrectOption == 'D'); }

            await _questionRepository.UpdateAsync(question);
            return true;
        }

        public async Task<bool> UpdatePassageAsync(UpdatePassageInput input)
        {
            var passage = await _groupRepository.FirstOrDefaultAsync(input.PassageGroupId);
            if (passage == null)
            {
                return false;
            }

            passage.GroupTitle = input.GroupTitle;
            passage.PassageText = input.PassageText;
            passage.ImageUrl = input.ImageUrl;

            await _groupRepository.UpdateAsync(passage);
            return true;
        }

        public async Task<SubmitExamResult> SubmitExamAsync(SubmitExamInput input)
        {
            var exam = await _examRepository.GetAll()
                .Include(e => e.Questions)
                .FirstOrDefaultAsync(e => e.Id == input.ExamId);

            if (exam == null)
            {
                throw new InvalidOperationException("Không tìm thấy đề thi.");
            }

            int correctCount = 0;
            int incorrectCount = 0;
            int skippedCount = 0;

            var attempt = new ExamAttempt
            {
                ExamId = exam.Id,
                StudentName = string.IsNullOrWhiteSpace(input.StudentName) ? "Thí sinh tự do" : input.StudentName,
                StudentCode = string.IsNullOrWhiteSpace(input.StudentCode) ? "SV001" : input.StudentCode,
                StartTime = DateTime.UtcNow.AddMinutes(-exam.DurationMinutes),
                SubmitTime = DateTime.UtcNow,
                Status = "Submitted"
            };

            foreach (var q in exam.Questions.OrderBy(q => q.QuestionNumber))
            {
                char? selected = null;
                if (input.Answers != null && input.Answers.ContainsKey(q.QuestionNumber))
                {
                    selected = input.Answers[q.QuestionNumber];
                }

                bool? isCorrect = null;
                if (!selected.HasValue)
                {
                    skippedCount++;
                }
                else
                {
                    isCorrect = (char.ToUpper(selected.Value) == char.ToUpper(q.CorrectOption));
                    if (isCorrect.Value) correctCount++;
                    else incorrectCount++;
                }

                attempt.StudentAnswers.Add(new StudentAnswer
                {
                    QuestionId = q.Id,
                    SelectedOption = selected,
                    IsCorrect = isCorrect,
                    AnsweredTime = DateTime.UtcNow
                });
            }

            attempt.TotalCorrect = correctCount;
            attempt.TotalIncorrect = incorrectCount;
            attempt.TotalSkipped = skippedCount;
            // Estimated TOEIC Reading score curve: ~5 pts per question with baseline
            attempt.Score = Math.Min(495, (int)Math.Round(correctCount * 4.95));

            int attemptId = await _attemptRepository.InsertAndGetIdAsync(attempt);

            return new SubmitExamResult
            {
                AttemptId = attemptId,
                ExamId = exam.Id,
                StudentName = attempt.StudentName,
                StudentCode = attempt.StudentCode,
                TotalQuestions = exam.Questions.Count,
                TotalCorrect = correctCount,
                TotalIncorrect = incorrectCount,
                TotalSkipped = skippedCount,
                Score = attempt.Score.Value,
                Status = attempt.Status,
                SubmitTime = attempt.SubmitTime.Value
            };
        }

        public async Task<List<SubmitExamResult>> GetExamAttemptsAsync()
        {
            var attempts = await _attemptRepository.GetAll()
                .OrderByDescending(a => a.SubmitTime)
                .Take(50)
                .ToListAsync();

            return attempts.Select(a => new SubmitExamResult
            {
                AttemptId = a.Id,
                ExamId = a.ExamId,
                StudentName = a.StudentName,
                StudentCode = a.StudentCode,
                TotalQuestions = 100,
                TotalCorrect = a.TotalCorrect,
                TotalIncorrect = a.TotalIncorrect,
                TotalSkipped = a.TotalSkipped,
                Score = a.Score ?? 0,
                Status = a.Status,
                SubmitTime = a.SubmitTime ?? DateTime.UtcNow
            }).ToList();
        }

        public async Task<bool> DeleteExamAsync(int examId)
        {
            var exam = await _examRepository.FirstOrDefaultAsync(examId);
            if (exam == null) return false;

            await _examRepository.DeleteAsync(exam);
            return true;
        }

        private static QuestionDto MapQuestionToDto(Question q)
        {
            return new QuestionDto
            {
                Id = q.Id,
                QuestionNumber = q.QuestionNumber,
                QuestionText = q.QuestionText,
                CorrectOption = q.CorrectOption,
                PassageGroupId = q.PassageGroupId,
                Options = q.Options.OrderBy(o => o.OptionLabel).Select(o => new AnswerOptionDto
                {
                    Id = o.Id,
                    OptionLabel = o.OptionLabel,
                    OptionText = o.OptionText,
                    IsCorrect = o.IsCorrect
                }).ToList()
            };
        }
    }
}
