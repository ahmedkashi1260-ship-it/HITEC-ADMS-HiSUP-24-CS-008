using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers;

public class FeePaymentController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _config;

    public FeePaymentController(ApplicationDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // GET: /FeePayment
    public async Task<IActionResult> Index()
    {
        var payments = await _context.FeePayments
            .Include(p => p.Student)
            .OrderByDescending(p => p.PaymentDate)
            .ToListAsync();
        return View(payments);
    }

    // GET: /FeePayment/Create
    public async Task<IActionResult> Create()
    {
        ViewBag.Students = await _context.Students
            .Where(s => s.IsActive)
            .ToListAsync();
        return View();
    }

    // POST: /FeePayment/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(int studentId, int feeStructureId, decimal amountPaid, string paymentMethod)
    {
        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("ProcessFeePayment", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StudentID", studentId);
            cmd.Parameters.AddWithValue("@FeeStructureID", feeStructureId);
            cmd.Parameters.AddWithValue("@AmountPaid", amountPaid);
            cmd.Parameters.AddWithValue("@PaymentMethod", paymentMethod);
            cmd.Parameters.AddWithValue("@TransactionReference", DBNull.Value);
            cmd.Parameters.AddWithValue("@ProcessedBy", DBNull.Value);

            var outputParam = new SqlParameter("@NewPaymentID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outputParam);
            await cmd.ExecuteNonQueryAsync();

            TempData["Success"] = "Payment processed successfully!";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
            ViewBag.Students = await _context.Students.Where(s => s.IsActive).ToListAsync();
            return View();
        }
    }

    // GET: /FeePayment/Defaulters
    public async Task<IActionResult> Defaulters()
    {
        // Simple version: students who have FeeStructure entries but no matching payment
        var students = await _context.Students
            .Include(s => s.Department)
            .Where(s => s.IsActive)
            .ToListAsync();
        return View(students);
    }
}