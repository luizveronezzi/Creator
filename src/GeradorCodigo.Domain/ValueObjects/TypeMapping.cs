namespace GeradorCodigo.Domain.ValueObjects;

/// <summary>Resultado do mapeamento de uma coluna MySQL para os alvos de geração.</summary>
public sealed record TypeMapping
{
    public required string CSharpType { get; init; }
    public required string TypeScriptType { get; init; }
    public required FormControlKind FormControl { get; init; }
    public required bool IsNumeric { get; init; }
    public required bool IsDateTime { get; init; }
    public required bool IsBoolean { get; init; }
    public required bool IsBinary { get; init; }
}

/// <summary>Componente de formulário Angular associado ao tipo da coluna.</summary>
public enum FormControlKind
{
    InputText,
    Textarea,
    InputNumber,
    DatePicker,
    DateTimePicker,
    Checkbox,
    Select,
    SelectForeignKey
}
