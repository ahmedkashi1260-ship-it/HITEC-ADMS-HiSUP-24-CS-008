using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class Faculty
{
    [Key]
    public int FacultyID { get; set; }

    [Required]
    [StringLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [StringLength(50)]
    public string LastName { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [StringLength(100)]
    public string Email { get; set; } = string.Empty;

    [StringLength(50)]
    public string? Designation { get; set; }

    [StringLength(20)]
    public string? Phone { get; set; }

    [ForeignKey("Department")]
    public int DepartmentID { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation
    public Department? Department { get; set; }
    public ICollection<Section> Sections { get; set; } = new List<Section>();
}