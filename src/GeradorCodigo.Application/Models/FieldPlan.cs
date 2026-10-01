using GeradorCodigo.Domain.ValueObjects;

namespace GeradorCodigo.Application.Models;

/// <summary>
/// Representa uma coluna já planejada para geração, reunindo metadados do banco,
/// mapeamento de tipos e convenções de nomenclatura.
/// </summary>
public sealed record FieldPlan
{
    public required string ColumnName { get; init; }
    public required string PropertyName { get; init; }
    public required string ParamName { get; init; }
    public required string TsProperty { get; init; }
    public required string CSharpType { get; init; }
    public required string TypeScriptType { get; init; }
    public required string FormControl { get; init; }
    public required bool IsPrimaryKey { get; init; }
    public required bool IsAutoIncrement { get; init; }
    public required bool IsNullable { get; init; }
    public required bool IsString { get; init; }
    public required bool IsText { get; init; }
    public required bool IsNumeric { get; init; }
    public required bool IsDecimal { get; init; }
    public required bool IsInteger { get; init; }
    public required bool IsDateTime { get; init; }
    public required bool IsDate { get; init; }
    public required bool IsTime { get; init; }
    public required bool IsBoolean { get; init; }
    public required bool IsBinary { get; init; }
    public required bool IsEnum { get; init; }
    public required bool HasMaxLength { get; init; }
    public int MaxLength { get; init; }
    public required bool HasPrecision { get; init; }
    public int Precision { get; init; }
    public int Scale { get; init; }
    public required bool IsForeignKey { get; init; }
    public string? ForeignKeyTable { get; init; }
    public string? ForeignKeyColumn { get; init; }
    public string? ForeignKeyEntityName { get; init; }
    public string? ForeignKeyRoute { get; init; }
    public string? ForeignKeyLabelProperty { get; init; }
    public string? ForeignKeyIdProperty { get; init; }
    public IReadOnlyList<string> EnumValues { get; init; } = [];
    public string? Comment { get; init; }
    public string? DefaultValue { get; init; }

    /// <summary>Campo obrigatório no formulário/validação (não anulável).</summary>
    public bool IsRequired => !IsNullable;

    /// <summary>Deve ser desabilitado no formulário (identidade/auto incremento).</summary>
    public bool IsReadOnly => IsAutoIncrement;

    /// <summary>Participa do formulário (identidade nunca é informada na inclusão).</summary>
    public bool IsEditable => !IsAutoIncrement;

    /// <summary>Campo válido para busca textual.</summary>
    public bool IsSearchable => IsString && !IsBinary;

    /// <summary>Campo válido para ordenação.</summary>
    public bool IsSortable => !IsBinary;

    /// <summary>Campo sem formatação visual especializada na listagem.</summary>
    public bool IsPlainListField =>
        !IsBoolean && !IsEnum && !IsDecimal && !IsDate && !IsFullDateTime;

    /// <summary>Rótulo exibido no formulário/tabela (comentário do banco ou nome da propriedade).
    /// Sanitizado para uso seguro em strings C#/TS e em HTML.</summary>
    public string DisplayName => Sanitize(string.IsNullOrWhiteSpace(Comment) ? PropertyName : Comment);

    private static string Sanitize(string value) => value
        .Replace("\"", "'")
        .Replace("<", string.Empty)
        .Replace(">", string.Empty)
        .Replace("\r", " ")
        .Replace("\n", " ")
        .Trim();

    /// <summary>Inicializador exigido por nullable reference types em C#.</summary>
    public string PropertyInitializer =>
        CSharpType is "string" or "byte[]" ? " = default!;" : string.Empty;

    /// <summary>Tem regras de validação relevantes para exibição de erro no formulário.</summary>
    public bool HasValidationRules => IsRequired || HasMaxLength;

    /// <summary>Data/hora completa (datetime/timestamp) — distinta de DATE e TIME.</summary>
    public bool IsFullDateTime => IsDateTime && !IsDate && !IsTime;

    /// <summary>Conversões necessárias entre Date do formulário e string da API.</summary>
    public bool NeedsDateConversion => IsDate;
    public bool NeedsDateTimeConversion => IsFullDateTime;
    public bool NeedsTimeConversion => IsTime;
    public bool NeedsPatchConversion => IsDate || IsFullDateTime || IsTime;

    // Controles mutuamente exclusivos (derivados do FormControl) para uso nos templates.
    public bool IsInputText => FormControl == "InputText";
    public bool IsTextarea => FormControl == "Textarea";
    public bool IsInputNumber => FormControl == "InputNumber";
    public bool IsDatePicker => FormControl == "DatePicker";
    public bool IsDateTimePicker => FormControl == "DateTimePicker";
    public bool IsCheckbox => FormControl == "Checkbox";
    public bool IsSelect => FormControl == "Select";
    public bool IsSelectForeignKey => FormControl == "SelectForeignKey";

    /// <summary>Possui regras de validação aplicáveis ao formulário.</summary>
    public bool HasFormRules => IsEditable && (IsRequired || HasMaxLength);

    /// <summary>Marcado como obrigatório no formulário (campos auto incremento são excluídos).</summary>
    public bool IsRequiredForm => IsEditable && IsRequired;
}
