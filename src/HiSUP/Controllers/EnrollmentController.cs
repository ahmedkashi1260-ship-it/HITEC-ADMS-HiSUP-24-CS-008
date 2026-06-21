using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers;

public class EnrollmentController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _config;

    public EnrollmentController(ApplicationDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // GET: /Enrollment
    public async Task<IActionResult> Index()
    {
        var enrollments = await _context.Enrollments
            .Include(e => e.Student)
            .Include(e => e.Section)
                .ThenInclude(s => s!.Course)
            .OrderByDescending(e => e.EnrollmentDate)
            .ToListAsync();
        return View(enrollments);
    }

    // GET: /Enrollment/Create
    public async Task<IActionResult> Create()
    {
        ViewBag.Students = await _context.Students.Where(s => s.IsActive).ToListAsync();
        ViewBag.Sections = await _context.Sections.Include(s => s.Course).ToListAsync();
        return View();
    }

    // POST: /Enrollment/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(int studentId, int sectionId)
    {
        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("EnrollInCourse", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StudentID", studentId);
            cmd.Parameters.AddWithValue("@SectionID", sectionId);

            var outputParam = new SqlParameter("@NewEnrollmentID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outputParam);
            await cmd.ExecuteNonQueryAsync();

            TempData["Success"] = "Student enrolled successfully!";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
            ViewBag.Students = await _context.Students.Where(s => s.IsActive).ToListAsync();
            ViewBag.Sections = await _context.Sections.Include(s => s.Course).ToListAsync();
            return View();
        }
    }
}