using GeradorCodigo.Domain.Metadata;

namespace GeradorCodigo.Application.Models;

/// <summary>
/// Plano completo de geração para uma tabela: combina metadados do banco com
/// nomenclaturas e é a fonte única de verdade usada pelos templates.
/// </summary>
public sealed record GenerationPlan
{
    public required string TableName { get; init; }
    public required string Schema { get; init; }
    public required string EntityName { get; init; }
    public required string EntityPlural { get; init; }
    public required string VariableName { get; init; }
    public required string FeatureName { get; init; }
    public required string Route { get; init; }
    public required string ProjectPrefix { get; init; }
    public required string SolutionFileName { get; init; }
    public required string TableComment { get; init; }
    public required IReadOnlyList<FieldPlan> Fields { get; init; }
    public required bool HasPrimaryKey { get; init; }

    /// <summary>
    /// Raiz dos namespaces do código gerado. Usa o sufixo "Module" para evitar a colisão
    /// clássica entre o nome da entidade (ex.: Customer) e o namespace raiz.
    /// </summary>
    public string NamespaceRoot => ProjectPrefix + "Module";
    public string? PrimaryKeyProperty { get; init; }
    public string? PrimaryKeyType { get; init; }
    public string? PrimaryKeyTsType { get; init; }
    public string? PrimaryKeyParam { get; init; }

    /// <summary>Tipo da chave primária sem nullable, usado como parâmetro de rota.</summary>
    public string PrimaryKeyRouteType => (PrimaryKeyType ?? "string").TrimEnd('?');

    /// <summary>Projetos incluídos no arquivo de solução gerado.</summary>
    public IReadOnlyList<SolutionProject> SolutionProjects =>
    [
        NewSolutionProject("Domain"),
        NewSolutionProject("Application"),
        NewSolutionProject("Infrastructure"),
        NewSolutionProject("Api"),
    ];

    public IReadOnlyList<FieldPlan> SearchableFields => Fields.Where(f => f.IsSearchable).ToList();
    public bool HasSearchableFields => SearchableFields.Count > 0;
    public IReadOnlyList<FieldPlan> SortableFields => Fields.Where(f => f.IsSortable).ToList();
    public IReadOnlyList<FieldPlan> EditableFields => Fields.Where(f => f.IsEditable).ToList();
    public IReadOnlyList<FieldPlan> EnumFields => Fields.Where(f => f.IsEnum).ToList();
    public IReadOnlyList<FieldPlan> ForeignKeyFields => Fields.Where(f => f.IsForeignKey).ToList();
    public IReadOnlyList<FieldPlan> ListFields => Fields.Where(f => !f.IsBinary).ToList();

    /// <summary>Itens do menu do shell Angular.</summary>
    public IReadOnlyList<MenuItem> MenuItems =>
    [
        new() { Label = EntityPlural, Icon = "pi pi-table", RouterLink = "/" + FeatureName },
    ];

    /// <summary>A chave primária identificada é auto incremento (somente leitura no formulário).</summary>
    public bool PrimaryKeyIsAutoIncrement =>
        Fields.FirstOrDefault(f => f.IsPrimaryKey)?.IsAutoIncrement ?? false;

    /// <summary>A tabela possui chave primária declarada (caso contrário, usa-se a primeira coluna).</summary>
    public bool HasTablePrimaryKey { get; init; }

    /// <summary>A chave primária é atribuída pelo cliente (não auto incremento).</summary>
    public bool HasAssignedPrimaryKey => HasPrimaryKey && !PrimaryKeyIsAutoIncrement;

    public IReadOnlyList<IndexPlan> IndexPlans { get; init; } = [];

    /// <summary>Quantidade de colunas exibidas na tela de listagem.</summary>
    public int ListFieldCount => ListFields.Count;

    /// <summary>A chave primária é numérica no TypeScript (permite Number(id) na rota).</summary>
    public bool PrimaryKeyIsNumericTs => PrimaryKeyTsType == "number";

    public static GenerationPlan Create(
        TableMetadata table,
        IReadOnlyDictionary<string, TableMetadata> relatedTables,
        Func<ColumnMetadata, Domain.ValueObjects.TypeMapping> mapType,
        Nomenclature nomenclature)
    {
        var fields = table.Columns
            .Select(column => BuildField(column, relatedTables, mapType, nomenclature))
            .ToList();

        var primaryKey = fields.FirstOrDefault(f => f.IsPrimaryKey) ?? fields.FirstOrDefault();
        var indexPlans = BuildIndexPlans(table, fields);

        return new GenerationPlan
        {
            TableName = table.Name,
            Schema = table.Schema,
            EntityName = nomenclature.EntityName,
            EntityPlural = nomenclature.EntityPlural,
            VariableName = nomenclature.VariableName,
            FeatureName = nomenclature.FeatureName,
            Route = nomenclature.Route,
            ProjectPrefix = nomenclature.ProjectPrefix,
            SolutionFileName = nomenclature.SolutionFileName,
            TableComment = table.Comment ?? string.Empty,
            Fields = fields,
            HasPrimaryKey = primaryKey is not null,
            HasTablePrimaryKey = table.PrimaryKeyColumns.Count > 0,
            PrimaryKeyProperty = primaryKey?.PropertyName,
            PrimaryKeyType = primaryKey?.CSharpType,
            PrimaryKeyTsType = primaryKey?.TypeScriptType,
            PrimaryKeyParam = primaryKey?.ParamName,
            IndexPlans = indexPlans,
        };
    }

    private static IReadOnlyList<IndexPlan> BuildIndexPlans(TableMetadata table, List<FieldPlan> fields)
    {
        var plans = new List<IndexPlan>();

        foreach (var index in table.Indexes)
        {
            var properties = index.Columns
                .Select(column => fields.FirstOrDefault(f =>
                    string.Equals(f.ColumnName, column, StringComparison.OrdinalIgnoreCase))?.PropertyName)
                .Where(name => name is not null)
                .Select(name => "x." + name)
                .ToList();

            if (properties.Count == 0 || properties.Count != index.Columns.Count)
            {
                continue;
            }

            plans.Add(new IndexPlan
            {
                Name = index.Name,
                IsUnique = index.IsUnique,
                KeyExpression = string.Join(", ", properties),
            });
        }

        return plans;
    }

    private SolutionProject NewSolutionProject(string suffix) => new()
    {
        Name = $"{ProjectPrefix}.{suffix}",
        RelativePath = $"{ProjectPrefix}.{suffix}\\{ProjectPrefix}.{suffix}.csproj",
        ProjectGuid = DeterministicGuid($"{ProjectPrefix}.{suffix}"),
    };

    private static string DeterministicGuid(string key)
    {
        var hash = System.Security.Cryptography.MD5.HashData(System.Text.Encoding.UTF8.GetBytes(key));
        return "{" + new Guid(hash).ToString().ToUpperInvariant() + "}";
    }

    private static FieldPlan BuildField(
        ColumnMetadata column,
        IReadOnlyDictionary<string, TableMetadata> relatedTables,
        Func<ColumnMetadata, Domain.ValueObjects.TypeMapping> mapType,
        Nomenclature nomenclature)
    {
        var mapping = mapType(column);
        var fk = column.ForeignKeys.FirstOrDefault();
        var property = nomenclature.ToPascal(column.Name);

        string? fkEntity = null, fkRoute = null, fkLabel = null, fkId = null;
        if (fk is not null)
        {
            fkEntity = nomenclature.SingularizePascal(fk.ReferencedTable);
            fkRoute = nomenclature.ToRoute(fk.ReferencedTable);
            fkId = nomenclature.ToPascal(fk.ReferencedColumn);
            fkLabel = ResolveLabelProperty(relatedTables, fk, nomenclature);
        }

        return new FieldPlan
        {
            ColumnName = column.Name,
            PropertyName = property,
            ParamName = nomenclature.ToCamel(column.Name),
            TsProperty = nomenclature.ToCamel(property),
            CSharpType = mapping.CSharpType,
            TypeScriptType = mapping.TypeScriptType,
            FormControl = mapping.FormControl.ToString(),
            IsPrimaryKey = column.IsPrimaryKey,
            IsAutoIncrement = column.IsAutoIncrement,
            IsNullable = column.IsNullable,
            IsString = column.IsString && mapping.CSharpType == "string",
            IsText = column.IsText,
            IsNumeric = mapping.IsNumeric,
            IsDecimal = string.Equals(column.DataType, "decimal", StringComparison.OrdinalIgnoreCase),
            IsInteger = mapping.CSharpType is "int" or "int?" or "long" or "long?" or "short" or "short?" or "byte" or "byte?",
            IsDateTime = mapping.IsDateTime,
            IsDate = column.DataType == "date",
            IsTime = column.DataType == "time",
            IsBoolean = mapping.IsBoolean,
            IsBinary = mapping.IsBinary,
            IsEnum = column.DataType == "enum",
            HasMaxLength = column.CharacterMaximumLength is > 0
                           || (column.DataType == "enum" && column.EnumValues.Count > 0),
            MaxLength = column.CharacterMaximumLength
                        ?? (column.DataType == "enum" ? column.EnumValues.Max(v => v.Length) : 0),
            HasPrecision = string.Equals(column.DataType, "decimal", StringComparison.OrdinalIgnoreCase)
                           && column.NumericPrecision is not null && column.NumericScale is not null,
            Precision = column.NumericPrecision ?? 0,
            Scale = column.NumericScale ?? 0,
            IsForeignKey = fk is not null,
            ForeignKeyTable = fk?.ReferencedTable,
            ForeignKeyColumn = fk?.ReferencedColumn,
            ForeignKeyEntityName = fkEntity,
            ForeignKeyRoute = fkRoute,
            ForeignKeyLabelProperty = fkLabel,
            ForeignKeyIdProperty = fkId,
            EnumValues = column.EnumValues,
            Comment = column.Comment,
            DefaultValue = column.Default,
        };
    }

    private static string ResolveLabelProperty(
        IReadOnlyDictionary<string, TableMetadata> relatedTables,
        ForeignKeyMetadata fk,
        Nomenclature nomenclature)
    {
        if (!relatedTables.TryGetValue(fk.ReferencedTable, out var related))
        {
            return nomenclature.ToPascal(fk.ReferencedColumn);
        }

        var label = related.Columns.FirstOrDefault(c =>
            !c.IsPrimaryKey && c.IsString && !c.IsText
            && string.Equals(c.DataType, "varchar", StringComparison.OrdinalIgnoreCase));

        label ??= related.Columns.FirstOrDefault(c => !c.IsPrimaryKey && c.IsString);
        return nomenclature.ToPascal(label?.Name ?? fk.ReferencedColumn);
    }
}
