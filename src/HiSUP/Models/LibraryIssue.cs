using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class LibraryIssue
{
    [Key]
    public int IssueID { get; set; }

    [ForeignKey("LibraryItem")]
    public int ItemID { get; set; }

    [ForeignKey("Student")]
    public int StudentID { get; set; }

    public DateTime IssueDate { get; set; } = DateTime.Now;

    public DateTime DueDate { get; set; }

    public DateTime? ReturnDate { get; set; }

    [StringLength(20)]
    public string Status { get; set; } = "Issued";

    public decimal? FineAmount { get; set; }

    // Navigation
    public LibraryItem? LibraryItem { get; set; }
    public Student? Student { get; set; }
}