using GeradorCodigo.Domain.Abstractions;
using GeradorCodigo.Domain.Metadata;
using GeradorCodigo.Domain.ValueObjects;

namespace GeradorCodigo.Infrastructure.Mappers;

/// <summary>
/// Mapeia tipos MySQL para tipos C#, TypeScript e controles de formulário Angular,
/// conforme a tabela de conversão definida na especificação.
/// </summary>
public sealed class MySqlTypeMapper : ITypeMapper
{
    public TypeMapping Map(ColumnMetadata column)
    {
        var csType = MapCSharp(column);
        var tsType = MapTypeScript(column);
        var control = MapFormControl(column);

        return new TypeMapping
        {
            CSharpType = csType,
            TypeScriptType = tsType,
            FormControl = control,
            IsNumeric = IsNumericType(column.DataType),
            IsDateTime = column.DataType is "datetime" or "timestamp" or "date" or "time",
            IsBoolean = column.DataType == "bit",
            IsBinary = IsBinaryType(column.DataType),
        };
    }

    private static string MapCSharp(ColumnMetadata column)
    {
        var baseType = column.DataType.ToLowerInvariant() switch
        {
            "int" or "integer" => "int",
            "bigint" => "long",
            "smallint" or "mediumint" => "short",
            "tinyint" => "byte",
            "decimal" or "numeric" => "decimal",
            "float" => "float",
            "double" or "real" => "double",
            "varchar" or "char" or "text" or "tinytext" or "mediumtext" or "longtext"
                or "enum" or "set" or "json" => "string",
            "date" => "DateOnly",
            "datetime" or "timestamp" => "DateTime",
            "time" => "TimeOnly",
            "bit" => "bool",
            "blob" or "tinyblob" or "mediumblob" or "longblob" or "binary" or "varbinary" => "byte[]",
            _ => "string",
        };

        var isValueType = baseType is not ("string" or "byte[]");
        if (column.IsNullable && isValueType)
        {
            return baseType + "?";
        }

        if (column.IsNullable && baseType == "string")
        {
            return "string?";
        }

        return baseType;
    }

    private static string MapTypeScript(ColumnMetadata column) => column.DataType.ToLowerInvariant() switch
    {
        "bit" => "boolean",
        "int" or "bigint" or "smallint" or "mediumint" or "tinyint"
            or "decimal" or "numeric" or "float" or "double" or "real" => "number",
        _ => "string",
    };

    private static FormControlKind MapFormControl(ColumnMetadata column)
    {
        var fk = column.ForeignKeys.FirstOrDefault();
        if (fk is not null)
        {
            return FormControlKind.SelectForeignKey;
        }

        return column.DataType.ToLowerInvariant() switch
        {
            "enum" => FormControlKind.Select,
            "bit" => FormControlKind.Checkbox,
            "date" => FormControlKind.DatePicker,
            "datetime" or "timestamp" => FormControlKind.DateTimePicker,
            "time" => FormControlKind.DatePicker,
            "text" or "tinytext" or "mediumtext" or "longtext" or "json" => FormControlKind.Textarea,
            "int" or "integer" or "bigint" or "smallint" or "mediumint" or "tinyint"
                or "decimal" or "numeric" or "float" or "double" or "real" => FormControlKind.InputNumber,
            _ => FormControlKind.InputText,
        };
    }

    private static bool IsNumericType(string dataType) => dataType.ToLowerInvariant() is
        "int" or "integer" or "bigint" or "smallint" or "mediumint" or "tinyint"
        or "decimal" or "numeric" or "float" or "double" or "real";

    private static bool IsBinaryType(string dataType) => dataType.ToLowerInvariant() is
        "blob" or "tinyblob" or "mediumblob" or "longblob" or "binary" or "varbinary";
}
