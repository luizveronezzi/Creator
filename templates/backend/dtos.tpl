namespace [[NamespaceRoot]].Application.DTOs;

/// <summary>Resposta da API para os registros de [[TableName]].</summary>
public sealed record [[EntityName]]ResponseDto
{
[[#each Fields]]
    /// <summary>[[ColumnName]] — [[DisplayName]]</summary>
    public [[CSharpType]] [[PropertyName]] { get; init; }[[PropertyInitializer]]
[[/each]]
}

/// <summary>Payload de criação (campos auto incremento são excluídos).</summary>
public sealed record [[EntityName]]CreateDto
{
[[#each EditableFields]]
    /// <summary>[[ColumnName]] — [[DisplayName]]</summary>
    public [[CSharpType]] [[PropertyName]] { get; init; }[[PropertyInitializer]]
[[/each]]
}

/// <summary>Payload de alteração (o identificador é informado na rota).</summary>
public sealed record [[EntityName]]UpdateDto
{
[[#each EditableFields]]
    /// <summary>[[ColumnName]] — [[DisplayName]]</summary>
    public [[CSharpType]] [[PropertyName]] { get; init; }[[PropertyInitializer]]
[[/each]]
}
