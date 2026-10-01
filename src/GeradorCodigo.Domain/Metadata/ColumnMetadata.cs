namespace GeradorCodigo.Domain.Metadata;

/// <summary>
/// Metadados brutos de uma coluna, lidos diretamente do INFORMATION_SCHEMA.
/// Não contém conhecimento de mapeamento para C# — isso é responsabilidade do TypeMapper.
/// </summary>
public sealed record ColumnMetadata
{
    public required string Name { get; init; }
    public required int OrdinalPosition { get; init; }
    public required string ColumnType { get; init; }
    public required string DataType { get; init; }
    public int? CharacterMaximumLength { get; init; }
    public int? NumericPrecision { get; init; }
    public int? NumericScale { get; init; }
    public int? DateTimePrecision { get; init; }
    public required bool IsNullable { get; init; }
    public string? Default { get; init; }
    public required bool IsAutoIncrement { get; init; }
    public required bool IsPrimaryKey { get; init; }
    public string? Comment { get; init; }
    public string? EnumName { get; init; }
    public IReadOnlyList<string> EnumValues { get; init; } = [];
    public IReadOnlyList<ForeignKeyMetadata> ForeignKeys { get; init; } = [];
    public IReadOnlyList<string> IndexNames { get; init; } = [];

    public bool IsString => DataType is "varchar" or "char" or "text" or "tinytext"
        or "mediumtext" or "longtext" or "enum" or "set";
    public bool IsText => DataType is "text" or "tinytext" or "mediumtext" or "longtext";
}
