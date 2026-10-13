using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace KiemTraGiuaKy.Exams
{
    public class ExamParseResult
    {
        public bool IsValid => Errors.Count == 0;
        public List<string> Errors { get; set; } = new List<string>();
        public List<string> Warnings { get; set; } = new List<string>();
        public Exam ParsedExam { get; set; }
    }

    public static class DocxExamParser
    {
        private static readonly XNamespace W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

        public static List<string> ExtractParagraphsFromDocx(Stream docxStream)
        {
            var paragraphs = new List<string>();
            using (var archive = new ZipArchive(docxStream, ZipArchiveMode.Read, true))
            {
                var entry = archive.GetEntry("word/document.xml");
                if (entry == null)
                {
                    throw new InvalidOperationException("Tệp tin không đúng định dạng Word (.docx) chuẩn (thiếu word/document.xml).");
                }

                using (var entryStream = entry.Open())
                {
                    var xdoc = XDocument.Load(entryStream);
                    foreach (var p in xdoc.Descendants(W + "p"))
                    {
                        var text = string.Join("", p.Descendants(W + "t").Select(t => (string)t));
                        if (!string.IsNullOrWhiteSpace(text))
                        {
                            paragraphs.Add(text.Trim());
                        }
                    }
                }
            }
            return paragraphs;
        }

        public static ExamParseResult ParseAndValidate(Stream docxStream)
        {
            var result = new ExamParseResult();
            List<string> lines;
            try
            {
                lines = ExtractParagraphsFromDocx(docxStream);
            }
            catch (Exception ex)
            {
                result.Errors.Add("Lỗi đọc file .docx: " + ex.Message);
                return result;
            }

            var fullText = string.Join("\n", lines);

            // 1. Validate Exam Title
            var examMatch = Regex.Match(fullText, @"\[EXAM:\s*([^\]]+)\]", RegexOptions.IgnoreCase);
            if (!examMatch.Success)
            {
                result.Errors.Add("Thiếu thẻ khai báo tiêu đề đề thi: [EXAM: <Tên đề thi>]");
            }

            var timeMatch = Regex.Match(fullText, @"\[TIME_MINUTES:\s*(\d+)\]", RegexOptions.IgnoreCase);
            int duration = 75;
            if (timeMatch.Success)
            {
                int.TryParse(timeMatch.Groups[1].Value, out duration);
            }

            var totalMatch = Regex.Match(fullText, @"\[TOTAL_QUESTIONS:\s*(\d+)\]", RegexOptions.IgnoreCase);
            int totalQuestionsExpected = 100;
            if (totalMatch.Success)
            {
                int.TryParse(totalMatch.Groups[1].Value, out totalQuestionsExpected);
            }

            var exam = new Exam
            {
                Title = examMatch.Success ? examMatch.Groups[1].Value.Trim() : "TOEIC Reading Test",
                Code = "Reading v02",
                DurationMinutes = duration > 0 ? duration : 75,
                TotalQuestions = totalQuestionsExpected,
                IsActive = true,
                CreationTime = DateTime.UtcNow
            };

            // 2. Validate Parts
            var partMatches = Regex.Matches(fullText, @"\[PART:\s*([567])\](.*?)\[/PART(?::\s*\1)?\]", RegexOptions.Singleline | RegexOptions.IgnoreCase);
            if (partMatches.Count == 0)
            {
                result.Errors.Add("Không tìm thấy thẻ phần thi: [PART: 5], [PART: 6], [PART: 7] kèm thẻ đóng tương ứng.");
                return result;
            }

            var foundParts = new HashSet<int>();
            var allQuestionsMap = new Dictionary<int, Question>();

            foreach (Match pMatch in partMatches)
            {
                int partNum = int.Parse(pMatch.Groups[1].Value);
                foundParts.Add(partNum);
                string partBody = pMatch.Groups[2].Value;

                var examPart = new ExamPart
                {
                    PartNumber = partNum,
                    Name = partNum == 5 ? "Part 5 - Incomplete Sentences" : (partNum == 6 ? "Part 6 - Text Completion" : "Part 7 - Reading Comprehension"),
                    TotalQuestions = 0
                };
                exam.Parts.Add(examPart);

                if (partNum == 5)
                {
                    // Part 5: Independent questions
                    ParseQuestionsInText(partBody, exam, examPart, null, allQuestionsMap, result.Errors);
                }
                else
                {
                    // Part 6 & 7: Grouped passages
                    var groupMatches = Regex.Matches(partBody, @"\[GROUP:\s*([^\]]+)\](.*?)\[/GROUP(?::\s*[^\]]+)?\]", RegexOptions.Singleline | RegexOptions.IgnoreCase);
                    if (groupMatches.Count == 0)
                    {
                        result.Errors.Add($"Part {partNum} bắt buộc phải có ít nhất một nhóm bài đọc định dạng [GROUP: <dải câu>] ... [/GROUP]");
                    }

                    int groupOrder = 1;
                    foreach (Match gMatch in groupMatches)
                    {
                        string groupCode = gMatch.Groups[1].Value.Trim();
                        string groupBody = gMatch.Groups[2].Value;

                        var passageMatch = Regex.Match(groupBody, @"\[PASSAGE\](.*?)\[/PASSAGE\]", RegexOptions.Singleline | RegexOptions.IgnoreCase);
                        if (!passageMatch.Success)
                        {
                            result.Errors.Add($"Nhóm [GROUP: {groupCode}] thiếu thẻ bài đọc [PASSAGE] ... [/PASSAGE]");
                        }

                        string passageText = passageMatch.Success ? passageMatch.Groups[1].Value.Trim() : "";
                        var passageGroup = new PassageGroup
                        {
                            GroupCode = groupCode,
                            PassageText = passageText,
                            OrderIndex = groupOrder++
                        };
                        examPart.PassageGroups.Add(passageGroup);

                        ParseQuestionsInText(groupBody, exam, examPart, passageGroup, allQuestionsMap, result.Errors);
                    }
                }

                examPart.TotalQuestions = examPart.Questions.Count;
            }

            // 3. Check for all 3 Parts
            foreach (var reqPart in new[] { 5, 6, 7 })
            {
                if (!foundParts.Contains(reqPart))
                {
                    result.Errors.Add($"Đề thi thiếu phần Part {reqPart}. Bắt buộc phải có đủ Part 5, Part 6 và Part 7.");
                }
            }

            // 4. Validate Question Continuity & Count (101 to 200)
            if (allQuestionsMap.Count != 100)
            {
                result.Errors.Add($"Tổng số lượng câu hỏi tìm thấy là {allQuestionsMap.Count}/100 câu. Đề thi TOEIC Reading chuẩn bắt buộc đủ 100 câu.");
            }

            for (int q = 101; q <= 200; q++)
            {
                if (!allQuestionsMap.ContainsKey(q))
                {
                    result.Errors.Add($"Thiếu số thứ tự câu hỏi: Câu {q}. Số thứ tự phải liên tục từ 101 đến 200.");
                }
            }

            if (result.IsValid)
            {
                result.ParsedExam = exam;
            }

            return result;
        }

        private static void ParseQuestionsInText(
            string text,
            Exam exam,
            ExamPart examPart,
            PassageGroup passageGroup,
            Dictionary<int, Question> allQuestionsMap,
            List<string> errors)
        {
            var qMatches = Regex.Matches(text, @"\[QUESTION:\s*(\d+)\](.*?)\[/QUESTION\]", RegexOptions.Singleline | RegexOptions.IgnoreCase);
            foreach (Match qMatch in qMatches)
            {
                int qNum = int.Parse(qMatch.Groups[1].Value);
                string qBody = qMatch.Groups[2].Value.Trim();

                if (allQuestionsMap.ContainsKey(qNum))
                {
                    errors.Add($"Trùng lặp số thứ tự câu hỏi: Câu {qNum} xuất hiện nhiều hơn 1 lần.");
                    continue;
                }

                // Check [ANSWER: X]
                var ansMatch = Regex.Match(qBody, @"\[ANSWER:\s*([ABCD])\]", RegexOptions.IgnoreCase);
                if (!ansMatch.Success)
                {
                    errors.Add($"Câu {qNum} thiếu thẻ đáp án đúng hoặc đáp án không hợp lệ: [ANSWER: A|B|C|D]");
                }
                char correctAns = ansMatch.Success ? ansMatch.Groups[1].Value.ToUpper()[0] : ' ';

                // Check 4 options [A], [B], [C], [D]
                var optAMatch = Regex.Match(qBody, @"\[A\]\s*(.*?)(?=\[B\]|$)", RegexOptions.Singleline | RegexOptions.IgnoreCase);
                var optBMatch = Regex.Match(qBody, @"\[B\]\s*(.*?)(?=\[C\]|$)", RegexOptions.Singleline | RegexOptions.IgnoreCase);
                var optCMatch = Regex.Match(qBody, @"\[C\]\s*(.*?)(?=\[D\]|$)", RegexOptions.Singleline | RegexOptions.IgnoreCase);
                var optDMatch = Regex.Match(qBody, @"\[D\]\s*(.*?)(?=\[ANSWER|\[/QUESTION\]|$)", RegexOptions.Singleline | RegexOptions.IgnoreCase);

                if (!optAMatch.Success || !optBMatch.Success || !optCMatch.Success || !optDMatch.Success)
                {
                    errors.Add($"Câu {qNum} không đủ 4 phương án lựa chọn [A], [B], [C], [D].");
                }

                string optAText = optAMatch.Success ? optAMatch.Groups[1].Value.Trim() : "";
                string optBText = optBMatch.Success ? optBMatch.Groups[1].Value.Trim() : "";
                string optCText = optCMatch.Success ? optCMatch.Groups[1].Value.Trim() : "";
                string optDText = optDMatch.Success ? Regex.Replace(optDMatch.Groups[1].Value, @"\[ANSWER.*?\]", "", RegexOptions.IgnoreCase).Trim() : "";

                // Prompt is before [A]
                int firstOptIdx = qBody.IndexOf("[A]", StringComparison.OrdinalIgnoreCase);
                string prompt = firstOptIdx > 0 ? qBody.Substring(0, firstOptIdx).Trim() : "";

                var question = new Question
                {
                    QuestionNumber = qNum,
                    QuestionText = prompt,
                    CorrectOption = correctAns,
                    OrderIndex = qNum,
                    PassageGroup = passageGroup
                };

                // Add Answer Options
                question.Options.Add(new AnswerOption { OptionLabel = 'A', OptionText = optAText, IsCorrect = (correctAns == 'A') });
                question.Options.Add(new AnswerOption { OptionLabel = 'B', OptionText = optBText, IsCorrect = (correctAns == 'B') });
                question.Options.Add(new AnswerOption { OptionLabel = 'C', OptionText = optCText, IsCorrect = (correctAns == 'C') });
                question.Options.Add(new AnswerOption { OptionLabel = 'D', OptionText = optDText, IsCorrect = (correctAns == 'D') });

                exam.Questions.Add(question);
                examPart.Questions.Add(question);
                if (passageGroup != null)
                {
                    passageGroup.Questions.Add(question);
                }

                allQuestionsMap[qNum] = question;
            }
        }
    }
}
