using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models;

public class FeePayment
{
    [Key]
    public int PaymentID { get; set; }

    [ForeignKey("Student")]
    public int StudentID { get; set; }

    public int FeeStructureID { get; set; }

    [Required]
    public decimal AmountPaid { get; set; }

    [StringLength(20)]
    public string PaymentMethod { get; set; } = string.Empty;

    public DateTime PaymentDate { get; set; } = DateTime.Now;

    [StringLength(20)]
    public string Status { get; set; } = "Paid";

    // Navigation
    public Student? Student { get; set; }
}