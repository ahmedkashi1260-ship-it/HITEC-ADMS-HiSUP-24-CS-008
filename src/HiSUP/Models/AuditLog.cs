using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models;

public class AuditLog
{
    [Key]
    public int AuditID { get; set; }

    [Required]
    [StringLength(50)]
    public string TableName { get; set; } = string.Empty;

    [Required]
    [StringLength(10)]
    public string OperationType { get; set; } = string.Empty;

    public int? RecordID { get; set; }

    public string? OldValue { get; set; }

    public string? NewValue { get; set; }

    [StringLength(100)]
    public string? ChangedBy { get; set; }

    public DateTime ChangedAt { get; set; } = DateTime.Now;
}