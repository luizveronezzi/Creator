using [[NamespaceRoot]].Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace [[NamespaceRoot]].Infrastructure.Persistence.Configurations;

/// <summary>Mapeamento EF Core gerado a partir dos metadados da tabela [[TableName]].</summary>
public sealed class [[EntityName]]Configuration : IEntityTypeConfiguration<[[EntityName]]>
{
    public void Configure(EntityTypeBuilder<[[EntityName]]> builder)
    {
        builder.ToTable("[[TableName]]");

[[#each Fields]]        builder.Property(x => x.[[PropertyName]])
            .HasColumnName("[[ColumnName]]")[[#if HasMaxLength]]
            .HasMaxLength([[MaxLength]])[[/if]][[#if IsRequired]]
            .IsRequired()[[/if]][[#if HasPrecision]]
            .HasPrecision([[Precision]], [[Scale]])[[/if]];
[[/each]]
        builder.HasKey(x => x.[[PrimaryKeyProperty]]);
[[#if PrimaryKeyIsAutoIncrement]]
        builder.Property(x => x.[[PrimaryKeyProperty]]).ValueGeneratedOnAdd();
[[/if]]
[[#each IndexPlans]]
        builder.HasIndex(x => new { [[KeyExpression]] })[[#if IsUnique]].IsUnique()[[/if]];
[[/each]]    }
}
