using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class Enrollment
{
    [Key]
    public int EnrollmentID { get; set; }

    [ForeignKey("Student")]
    public int StudentID { get; set; }

    [ForeignKey("Section")]
    public int SectionID { get; set; }

    public DateTime EnrollmentDate { get; set; } = DateTime.Now;

    [StringLength(20)]
    public string Status { get; set; } = "Active";

    // Navigation
    public Student? Student { get; set; }
    public Section? Section { get; set; }
    public Grade? Grade { get; set; }
}