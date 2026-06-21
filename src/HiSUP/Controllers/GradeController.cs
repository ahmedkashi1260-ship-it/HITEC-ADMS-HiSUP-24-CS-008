using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers;

public class GradeController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _config;

    public GradeController(ApplicationDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // GET: /Grade
    public async Task<IActionResult> Index()
    {
        var grades = await _context.Grades
            .Include(g => g.Enrollment)
                .ThenInclude(e => e!.Student)
            .Include(g => g.Enrollment)
                .ThenInclude(e => e!.Section)
                    .ThenInclude(s => s!.Course)
            .OrderByDescending(g => g.PublishedDate)
            .ToListAsync();
        return View(grades);
    }

    // GET: /Grade/Transcript/5  (5 = StudentID)
    public async Task<IActionResult> Transcript(int id)
    {
        var transcriptData = new List<dynamic>();

        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("GenerateTranscript", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StudentID", id);

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                transcriptData.Add(new
                {
                    CourseCode = reader["CourseCode"].ToString(),
                    CourseTitle = reader["CourseTitle"].ToString(),
                    CreditHours = reader["CreditHours"],
                    SemesterTerm = reader["SemesterTerm"].ToString(),
                    AcademicYear = reader["AcademicYear"].ToString(),
                    LetterGrade = reader["LetterGrade"]?.ToString() ?? "-",
                    GradePoint = reader["GradePoint"]
                });
            }
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
        }

        var student = await _context.Students.FindAsync(id);
        ViewBag.Student = student;
        return View(transcriptData);
    }
}