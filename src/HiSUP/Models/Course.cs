using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class Course
{
    [Key]
    public int CourseID { get; set; }

    [Required]
    [StringLength(20)]
    public string CourseCode { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string CourseTitle { get; set; } = string.Empty;

    public int CreditHours { get; set; }

    public int Semester { get; set; }

    public int? PrerequisiteCourseID { get; set; }

    public int ProgramID { get; set; }

    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<Section> Sections { get; set; } = new List<Section>();
}