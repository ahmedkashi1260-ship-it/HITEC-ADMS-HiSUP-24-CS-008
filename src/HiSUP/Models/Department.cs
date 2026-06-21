using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models;

public class Department
{
    [Key]
    public int DepartmentID { get; set; }

    [Required]
    [StringLength(100)]
    public string DeptName { get; set; } = string.Empty;

    [Required]
    [StringLength(10)]
    public string DeptCode { get; set; } = string.Empty;

    public int? EstablishedYear { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation
    public ICollection<Student> Students { get; set; } = new List<Student>();
    public ICollection<Faculty> Faculty { get; set; } = new List<Faculty>();
}