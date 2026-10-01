namespace [[NamespaceRoot]].Domain.Entities;

/// <summary>
/// Entidade mapeada da tabela [[TableName]] com base nos metadados do INFORMATION_SCHEMA.[[#if TableComment]]
/// [[TableComment]][[/if]]
/// </summary>
public sealed class [[EntityName]]
{
[[#each Fields]]
    /// <summary>[[ColumnName]] — [[DisplayName]]</summary>
    public [[CSharpType]] [[PropertyName]] { get; set; }[[PropertyInitializer]]
[[/each]]
}
