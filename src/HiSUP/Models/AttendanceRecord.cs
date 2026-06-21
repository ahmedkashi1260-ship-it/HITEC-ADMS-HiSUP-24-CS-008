using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class AttendanceRecord
{
    [Key]
    public int AttendanceID { get; set; }

    [ForeignKey("Student")]
    public int StudentID { get; set; }

    [ForeignKey("Section")]
    public int SectionID { get; set; }

    public DateTime AttendanceDate { get; set; }

    [Required]
    [StringLength(10)]
    public string Status { get; set; } = "Present";

    [StringLength(200)]
    public string? Remarks { get; set; }

    // Navigation
    public Student? Student { get; set; }
    public Section? Section { get; set; }
}