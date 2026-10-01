using [[NamespaceRoot]].Domain.Entities;

namespace [[NamespaceRoot]].Application.Interfaces;

/// <summary>Porta de persistência de [[EntityName]] (implementada na Infrastructure).</summary>
public interface I[[EntityName]]Repository
{
    Task<(IReadOnlyList<[[EntityName]]> Items, int TotalCount)> ListAsync(
        int page,
        int pageSize,
        string? sortBy,
        string? sortDir,
        string? search,
        string? filterColumn,
        string? filterValue,
        CancellationToken cancellationToken = default);

    Task<[[EntityName]]?> GetByIdAsync([[PrimaryKeyRouteType]] id, CancellationToken cancellationToken = default);

    Task InsertAsync([[EntityName]] entity, CancellationToken cancellationToken = default);

    Task UpdateAsync([[EntityName]] entity, CancellationToken cancellationToken = default);

    Task DeleteAsync([[EntityName]] entity, CancellationToken cancellationToken = default);
}
