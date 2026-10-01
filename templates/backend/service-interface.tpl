using [[NamespaceRoot]].Application.Common;
using [[NamespaceRoot]].Application.DTOs;

namespace [[NamespaceRoot]].Application.Interfaces;

/// <summary>Serviço de aplicação para [[EntityPlural]] (usado por REST e GraphQL).</summary>
public interface I[[EntityName]]Service
{
    Task<PagedResult<[[EntityName]]ResponseDto>> ListAsync(
        int page,
        int pageSize,
        string? sortBy,
        string? sortDir,
        string? search,
        string? filterColumn,
        string? filterValue,
        CancellationToken cancellationToken = default);

    Task<[[EntityName]]ResponseDto?> GetAsync([[PrimaryKeyRouteType]] id, CancellationToken cancellationToken = default);

    Task<[[EntityName]]ResponseDto> CreateAsync([[EntityName]]CreateDto dto, CancellationToken cancellationToken = default);

    Task<[[EntityName]]ResponseDto?> UpdateAsync(
        [[PrimaryKeyRouteType]] id,
        [[EntityName]]UpdateDto dto,
        CancellationToken cancellationToken = default);

    Task<bool> DeleteAsync([[PrimaryKeyRouteType]] id, CancellationToken cancellationToken = default);
}
