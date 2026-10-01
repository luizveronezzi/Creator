using HotChocolate;
using [[NamespaceRoot]].Application.Common;
using [[NamespaceRoot]].Application.DTOs;
using [[NamespaceRoot]].Application.Interfaces;

namespace [[NamespaceRoot]].Api.GraphQL;

/// <summary>
/// Queries GraphQL de [[EntityPlural]]. Reutiliza a camada Application/Infrastructure —
/// não há acesso direto ao banco de dados a partir do GraphQL.
/// </summary>
public sealed class [[EntityName]]Query(I[[EntityName]]Service service)
{
    [GraphQLName("[[Route]]")]
    public Task<PagedResult<[[EntityName]]ResponseDto>> Get[[EntityPlural]]Async(
        int page = 1,
        int pageSize = 20,
        string? sortBy = null,
        string? sortDir = null,
        string? search = null,
        CancellationToken cancellationToken = default)
        => service.ListAsync(page, pageSize, sortBy, sortDir, search, null, null, cancellationToken);

    [GraphQLName("[[VariableName]]")]
    public Task<[[EntityName]]ResponseDto?> Get[[EntityName]]Async(
        [[PrimaryKeyRouteType]] id,
        CancellationToken cancellationToken = default)
        => service.GetAsync(id, cancellationToken);
}
