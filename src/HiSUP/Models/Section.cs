using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class Section
{
    [Key]
    public int SectionID { get; set; }

    [Required]
    [StringLength(20)]
    public string SectionName { get; set; } = string.Empty;

    [ForeignKey("Course")]
    public int CourseID { get; set; }

    [ForeignKey("Faculty")]
    public int FacultyID { get; set; }

    [StringLength(10)]
    public string? SemesterTerm { get; set; }

    [StringLength(10)]
    public string? AcademicYear { get; set; }

    public int MaxSeats { get; set; }

    public int SeatsFilled { get; set; } = 0;

    // Navigation
    public Course? Course { get; set; }
    public Faculty? Faculty { get; set; }
    public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
}