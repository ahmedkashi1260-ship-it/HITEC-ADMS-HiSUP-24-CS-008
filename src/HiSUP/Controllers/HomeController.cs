using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using HiSUP.Models;

namespace HiSUP.Controllers;

public class HomeController : Controller
{
    private readonly UserManager<IdentityUser> _userManager;

    public HomeController(UserManager<IdentityUser> userManager)
    {
        _userManager = userManager;
    }

    public async Task<IActionResult> Index()
    {
        // If user is not logged in, show the public dashboard (read-only demo view)
        if (User.Identity == null || !User.Identity.IsAuthenticated)
        {
            return View();
        }

        var user = await _userManager.GetUserAsync(User);
        if (user == null)
        {
            return View();
        }

        // Check role and redirect to the right dashboard
        if (await _userManager.IsInRoleAsync(user, "Student"))
        {
            return RedirectToAction("Index", "StudentDashboard");
        }
        else if (await _userManager.IsInRoleAsync(user, "Faculty"))
        {
            return RedirectToAction("Index", "FacultyDashboard");
        }
        else if (await _userManager.IsInRoleAsync(user, "Finance"))
        {
            return RedirectToAction("Index", "FeePayment");
        }
        // Admin or no specific role assigned yet -> default admin dashboard
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}