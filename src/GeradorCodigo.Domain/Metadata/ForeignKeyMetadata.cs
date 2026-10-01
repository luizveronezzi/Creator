namespace GeradorCodigo.Domain.Metadata;

/// <summary>Foreign key encontrada para uma coluna.</summary>
public sealed record ForeignKeyMetadata
{
    public required string ConstraintName { get; init; }
    public required string ColumnName { get; init; }
    public required string ReferencedTable { get; init; }
    public required string ReferencedColumn { get; init; }
}
