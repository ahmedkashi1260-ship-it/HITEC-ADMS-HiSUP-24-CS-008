using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class Grade
{
    [Key]
    public int GradeID { get; set; }

    [ForeignKey("Enrollment")]
    public int EnrollmentID { get; set; }

    public decimal? MarksObtained { get; set; }

    [StringLength(2)]
    public string? LetterGrade { get; set; }

    public decimal? GradePoint { get; set; }

    public DateTime? PublishedDate { get; set; }

    // Navigation
    public Enrollment? Enrollment { get; set; }
}