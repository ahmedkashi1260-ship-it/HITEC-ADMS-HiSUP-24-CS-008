using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers;

public class LibraryController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _config;

    public LibraryController(ApplicationDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // GET: /Library
    public async Task<IActionResult> Index(string search = "")
    {
        var items = await _context.LibraryItems
            .Where(i => i.IsActive && 
                (string.IsNullOrEmpty(search) || 
                 i.Title.Contains(search) || 
                 i.Author.Contains(search)))
            .OrderBy(i => i.Title)
            .ToListAsync();

        ViewBag.Search = search;
        return View(items);
    }

    // GET: /Library/Overdue
    public async Task<IActionResult> Overdue()
    {
        var overdue = await _context.LibraryIssues
            .Include(i => i.Student)
            .Include(i => i.LibraryItem)
            .Where(i => i.Status == "Issued" && i.DueDate < DateTime.Today)
            .OrderBy(i => i.DueDate)
            .ToListAsync();

        return View(overdue);
    }

    // GET: /Library/Issue
    public async Task<IActionResult> Issue()
    {
        ViewBag.Students = await _context.Students
            .Where(s => s.IsActive)
            .ToListAsync();
        ViewBag.Items = await _context.LibraryItems
            .Where(i => i.IsActive && i.CopiesAvailable > 0)
            .ToListAsync();
        return View();
    }

    // POST: /Library/Issue
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Issue(int studentId, int itemId, DateTime dueDate)
    {
        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("IssueLibraryBook", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StudentID", studentId);
            cmd.Parameters.AddWithValue("@ItemID", itemId);
            cmd.Parameters.AddWithValue("@DueDate", dueDate);

            var outputParam = new SqlParameter("@NewIssueID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outputParam);
            await cmd.ExecuteNonQueryAsync();

            TempData["Success"] = "Book issued successfully!";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
            return RedirectToAction(nameof(Issue));
        }
    }

    // POST: /Library/Return
    [HttpPost]
    public async Task<IActionResult> Return(int issueId)
    {
        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("ReturnLibraryBook", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@IssueID", issueId);

            await cmd.ExecuteNonQueryAsync();

            TempData["Success"] = "Book returned successfully!";
            return RedirectToAction(nameof(Overdue));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
            return RedirectToAction(nameof(Overdue));
        }
    }
}