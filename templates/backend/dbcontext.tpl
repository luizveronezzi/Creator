using [[NamespaceRoot]].Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace [[NamespaceRoot]].Infrastructure.Persistence;

/// <summary>Contexto EF Core da tabela [[TableName]].</summary>
public sealed class [[NamespaceRoot]]DbContext(DbContextOptions<[[NamespaceRoot]]DbContext> options) : DbContext(options)
{
    public DbSet<[[EntityName]]> [[EntityPlural]] => Set<[[EntityName]]>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfiguration(new Configurations.[[EntityName]]Configuration());
    }
}
