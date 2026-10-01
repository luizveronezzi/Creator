using Microsoft.EntityFrameworkCore;
using [[NamespaceRoot]].Application.Interfaces;
using [[NamespaceRoot]].Domain.Entities;
using [[NamespaceRoot]].Infrastructure.Persistence;

namespace [[NamespaceRoot]].Infrastructure.Repositories;

/// <summary>Repositório EF Core para a tabela [[TableName]].</summary>
public sealed class [[EntityName]]Repository([[NamespaceRoot]]DbContext context) : I[[EntityName]]Repository
{
    public async Task<(IReadOnlyList<[[EntityName]]> Items, int TotalCount)> ListAsync(
        int page,
        int pageSize,
        string? sortBy,
        string? sortDir,
        string? search,
        string? filterColumn,
        string? filterValue,
        CancellationToken cancellationToken = default)
    {
        var query = context.[[EntityPlural]].AsNoTracking().AsQueryable();

[[#if SearchableFields]]
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x =>
[[#each SearchableFields]]                (x.[[PropertyName]] != null && x.[[PropertyName]].Contains(term)) ||
[[/each]]                false);
        }

        if (!string.IsNullOrWhiteSpace(filterColumn) && !string.IsNullOrWhiteSpace(filterValue))
        {
            var column = filterColumn.Trim().ToLowerInvariant();
            var value = filterValue.Trim();
            query = column switch
            {
[[#each SearchableFields]]                "[[ParamName]]" => query.Where(x => x.[[PropertyName]] != null && x.[[PropertyName]].Contains(value)),
[[/each]]                _ => query,
            };
        }
[[/if]]

        var total = await query.CountAsync(cancellationToken);

        var sortDescending = string.Equals(sortDir, "desc", StringComparison.OrdinalIgnoreCase);
        query = sortBy?.Trim().ToLowerInvariant() switch
        {
[[#each SortableFields]]            "[[ParamName]]" => sortDescending
                ? query.OrderByDescending(x => x.[[PropertyName]])
                : query.OrderBy(x => x.[[PropertyName]]),
[[/each]]            _ => sortDescending
                ? query.OrderByDescending(x => x.[[PrimaryKeyProperty]])
                : query.OrderBy(x => x.[[PrimaryKeyProperty]]),
        };

        var safePage = Math.Max(1, page);
        var safePageSize = pageSize <= 0 ? 20 : pageSize;

        var items = await query
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync(cancellationToken);

        return (items, total);
    }

    public async Task<[[EntityName]]?> GetByIdAsync([[PrimaryKeyRouteType]] id, CancellationToken cancellationToken = default) =>
        await context.[[EntityPlural]]
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.[[PrimaryKeyProperty]] == id, cancellationToken);

    public async Task InsertAsync([[EntityName]] entity, CancellationToken cancellationToken = default)
    {
        await context.[[EntityPlural]].AddAsync(entity, cancellationToken);
        await context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync([[EntityName]] entity, CancellationToken cancellationToken = default)
    {
        context.[[EntityPlural]].Update(entity);
        await context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync([[EntityName]] entity, CancellationToken cancellationToken = default)
    {
        context.[[EntityPlural]].Remove(entity);
        await context.SaveChangesAsync(cancellationToken);
    }
}
