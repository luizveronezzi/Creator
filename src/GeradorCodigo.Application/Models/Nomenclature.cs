namespace GeradorCodigo.Application.Models;

/// <summary>
/// Convenções de nomenclatura derivadas do nome da tabela MySQL.
/// Regras simples e documentadas no README (heurística de singularização em inglês).
/// </summary>
public sealed record Nomenclature
{
    public required string TableName { get; init; }
    public required string EntityName { get; init; }
    public required string EntityPlural { get; init; }
    public required string VariableName { get; init; }
    public required string FeatureName { get; init; }
    public required string Route { get; init; }
    public required string ProjectPrefix { get; init; }
    public required string SolutionFileName { get; init; }

    public string ToPascal(string raw) => ToWords(raw, capitalizeFirst: true);
    public string ToCamel(string raw) => ToWords(raw, capitalizeFirst: false);
    // Rota da tabela referenciada por FK: mesma convenção do Route (plural em snake_case),
    // para bater com o endpoint gerado para a tabela alvo (ex.: /api/countries).
    public string ToRoute(string tableName) => ToSnake(ToWords(tableName, capitalizeFirst: true)).ToLowerInvariant();

    public string SingularizePascal(string tableName) => Singularize(tableName);

    private static string Singularize(string tableName)
    {
        var pascal = ToWords(tableName, capitalizeFirst: true);
        var lower = pascal.ToLowerInvariant();

        if (lower.EndsWith("ies") && pascal.Length > 3)
        {
            return pascal[..^3] + "y";
        }

        if (lower.EndsWith("ss") || lower.EndsWith("us") || lower.EndsWith("is"))
        {
            return pascal;
        }

        if (lower.EndsWith("ses") || lower.EndsWith("xes") || lower.EndsWith("zes")
            || lower.EndsWith("ches") || lower.EndsWith("shes"))
        {
            return pascal[..^2];
        }

        if (lower.EndsWith("s"))
        {
            return pascal[..^1];
        }

        return pascal;
    }

    public static Nomenclature From(string tableName)
    {
        var pluralPascal = ToWords(tableName, capitalizeFirst: true);
        var entity = Singularize(tableName);
        var feature = ToSnake(pluralPascal).ToLowerInvariant();

        return new Nomenclature
        {
            TableName = tableName,
            EntityName = entity,
            EntityPlural = pluralPascal,
            VariableName = ToWords(entity, capitalizeFirst: false),
            FeatureName = feature,
            Route = feature,
            ProjectPrefix = entity,
            SolutionFileName = $"{entity}.sln",
        };
    }

    private static string ToWords(string raw, bool capitalizeFirst)
    {
        var parts = raw.Split(['_', '-', ' ', '.'], StringSplitOptions.RemoveEmptyEntries);
        var words = new List<string>();

        foreach (var part in parts)
        {
            var segments = SplitCamel(part);
            for (var i = 0; i < segments.Length; i++)
            {
                var segment = segments[i];
                var shouldCapitalize = capitalizeFirst || i > 0;
                words.Add(shouldCapitalize
                    ? char.ToUpperInvariant(segment[0]) + segment[1..].ToLowerInvariant()
                    : char.ToLowerInvariant(segment[0]) + segment[1..].ToLowerInvariant());
            }
        }

        return string.Concat(words);
    }

    private static string[] SplitCamel(string value)
    {
        var normalized = string.Concat(value.Select((c, i) =>
            i > 0 && char.IsUpper(c) && !char.IsUpper(value[i - 1]) ? "_" + c : c.ToString()));
        return normalized.Split('_', StringSplitOptions.RemoveEmptyEntries);
    }

    private static string ToSnake(string pascal) =>
        string.Concat(pascal.Select((c, i) => i > 0 && char.IsUpper(c) ? "_" + c : c.ToString())).ToLowerInvariant();
}
