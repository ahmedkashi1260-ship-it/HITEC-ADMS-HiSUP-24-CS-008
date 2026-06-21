using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models;

public class LibraryItem
{
    [Key]
    public int ItemID { get; set; }

    [Required]
    [StringLength(200)]
    public string Title { get; set; } = string.Empty;

    [StringLength(100)]
    public string? Author { get; set; }

    [StringLength(20)]
    public string? ItemType { get; set; }

    public int TotalCopies { get; set; }

    public int CopiesAvailable { get; set; }

    [StringLength(20)]
    public string? ISBN { get; set; }

    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<LibraryIssue> LibraryIssues { get; set; } = new List<LibraryIssue>();
}