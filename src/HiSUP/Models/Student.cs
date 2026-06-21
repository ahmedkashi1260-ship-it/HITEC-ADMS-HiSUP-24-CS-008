using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class Student
{
    [Key]
    public int StudentID { get; set; }

    [Required]
    [StringLength(20)]
    public string RollNumber { get; set; } = string.Empty;

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

    [StringLength(256)]
    public string? CNIC { get; set; }

    [StringLength(20)]
    public string? Phone { get; set; }

    public DateTime? DateOfBirth { get; set; }

    [StringLength(10)]
    public string? Gender { get; set; }

    [ForeignKey("Department")]
    public int DepartmentID { get; set; }

    public int EnrollmentYear { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation
    public Department? Department { get; set; }
    public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
    public ICollection<FeePayment> FeePayments { get; set; } = new List<FeePayment>();
}