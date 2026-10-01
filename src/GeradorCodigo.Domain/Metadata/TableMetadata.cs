namespace GeradorCodigo.Domain.Metadata;

/// <summary>Estrutura completa de uma tabela, obtida do INFORMATION_SCHEMA.</summary>
public sealed record TableMetadata
{
    public required string Name { get; init; }
    public required string Schema { get; init; }
    public string? Comment { get; init; }
    public required IReadOnlyList<ColumnMetadata> Columns { get; init; }
    public required IReadOnlyList<string> PrimaryKeyColumns { get; init; }
    public required IReadOnlyList<IndexMetadata> Indexes { get; init; }

    public IEnumerable<ColumnMetadata> ForeignKeyColumns =>
        Columns.Where(c => c.ForeignKeys.Count > 0);

    public ColumnMetadata? FindColumn(string name) =>
        Columns.FirstOrDefault(c => string.Equals(c.Name, name, StringComparison.OrdinalIgnoreCase));
}
