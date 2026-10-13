using System.IO;
using System.Linq;
using KiemTraGiuaKy.Exams;
using Shouldly;
using Xunit;

namespace KiemTraGiuaKy.Tests
{
    public class DocxParser_Tests
    {
        [Fact]
        public void Should_Parse_TOEIC_Reading_v02_Docx_Successfully()
        {
            var filePath = @"d:\KTGK LTDD\TOEIC_Reading_v02.docx";
            File.Exists(filePath).ShouldBeTrue($"File {filePath} must exist.");

            using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                var result = DocxExamParser.ParseAndValidate(stream);
                
                result.Errors.ShouldBeEmpty(string.Join("\n", result.Errors));
                result.IsValid.ShouldBeTrue();
                result.ParsedExam.ShouldNotBeNull();
                result.ParsedExam.Questions.Count.ShouldBe(100);
                result.ParsedExam.Parts.Count.ShouldBe(3);

                // Part 5 check
                var part5 = result.ParsedExam.Parts.FirstOrDefault(p => p.PartNumber == 5);
                part5.ShouldNotBeNull();
                part5.Questions.Count.ShouldBe(30);

                var q101 = part5.Questions.FirstOrDefault(q => q.QuestionNumber == 101);
                q101.ShouldNotBeNull();
                var optD = q101.Options.FirstOrDefault(o => o.OptionLabel == 'D');
                optD.ShouldNotBeNull();
                optD.OptionText.ShouldBe("herself");

                // Part 6 check
                var part6 = result.ParsedExam.Parts.FirstOrDefault(p => p.PartNumber == 6);
                part6.ShouldNotBeNull();
                part6.Questions.Count.ShouldBe(16);

                // Part 7 check
                var part7 = result.ParsedExam.Parts.FirstOrDefault(p => p.PartNumber == 7);
                part7.ShouldNotBeNull();
                part7.Questions.Count.ShouldBe(54);
            }
        }
    }
}
