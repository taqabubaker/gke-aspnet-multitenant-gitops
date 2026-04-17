using Microsoft.EntityFrameworkCore;
using MyApp.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

// Read connection string from environment variable or appsettings.json
var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING") 
                       ?? builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

// Ensure database is created and seeded
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
    
    if (!db.Transactions.Any())
    {
        var random = new Random();
        var descriptions = new[] { "Payment from Client A", "Office Supplies", "Cloud Hosting Service", "Software License", "Consulting Fee", "Team Lunch" };
        var transactions = new List<Transaction>();
        
        for (int i = 0; i < 10; i++)
        {
            transactions.Add(new Transaction
            {
                Date = DateTime.Now.AddDays(-random.Next(1, 30)),
                Description = descriptions[random.Next(descriptions.Length)] + $" (Random {i+1})",
                Amount = Math.Round((decimal)(random.NextDouble() * 3000 - 1000), 2)
            });
        }
        
        db.Transactions.AddRange(transactions);
        db.SaveChanges();
    }
}

app.Run();

// Inline DbContext for simplicity
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    public DbSet<Transaction> Transactions => Set<Transaction>();
}
