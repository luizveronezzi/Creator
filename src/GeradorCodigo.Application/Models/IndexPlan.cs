namespace GeradorCodigo.Application.Models;

/// <summary>Índice planejado para geração da configuração do EF Core.</summary>
public sealed record IndexPlan
{
    public required string Name { get; init; }
    public required bool IsUnique { get; init; }

    /// <summary>Expressão lambda das colunas, ex.: "x.Name, x.City".</summary>
    public required string KeyExpression { get; init; }
}

/// <summary>Projeto incluído no arquivo .sln gerado.</summary>
public sealed record SolutionProject
{
    public required string Name { get; init; }
    public required string RelativePath { get; init; }
    public required string ProjectGuid { get; init; }
}

/// <summary>Item de menu do shell do frontend.</summary>
public sealed record MenuItem
{
    public required string Label { get; init; }
    public required string Icon { get; init; }
    public required string RouterLink { get; init; }
}
