using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using MyApp.Models;

namespace MyApp.Pages
{
    public class IndexModel : PageModel
    {
        private readonly AppDbContext _context;

        public IndexModel(AppDbContext context)
        {
            _context = context;
        }

        public string PodName { get; set; } = "N/A";
        public string PodIp { get; set; } = "N/A";
        public string PodNamespace { get; set; } = "N/A";
        public string DatabaseConnected { get; set; } = "N/A";
        public List<Transaction> Transactions { get; set; } = new();

        public async Task OnGetAsync()
        {
            // Read environment variables injected by Kubernetes Downward API
            PodName = Environment.GetEnvironmentVariable("POD_NAME") ?? "Not in K8s";
            PodIp = Environment.GetEnvironmentVariable("POD_IP") ?? "Not in K8s";
            PodNamespace = Environment.GetEnvironmentVariable("POD_NAMESPACE") ?? "Not in K8s";
            
            // Read database identifier from environment
            DatabaseConnected = Environment.GetEnvironmentVariable("DB_INSTANCE") ?? "Unknown DB";

            // Fetch data from database
            Transactions = await _context.Transactions.ToListAsync();
        }
    }
}
