namespace GeradorCodigo.Domain.Metadata;

/// <summary>Índice (não-PK) da tabela, com colunas na ordem correta.</summary>
public sealed record IndexMetadata
{
    public required string Name { get; init; }
    public required bool IsUnique { get; init; }
    public required IReadOnlyList<string> Columns { get; init; }
}
