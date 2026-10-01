using FluentValidation;
using [[NamespaceRoot]].Application.Common;
using [[NamespaceRoot]].Application.DTOs;
using [[NamespaceRoot]].Application.Interfaces;
using [[NamespaceRoot]].Domain.Entities;

namespace [[NamespaceRoot]].Application.Services;

/// <summary>Regras de aplicação de [[EntityPlural]]: validação, paginação e mapeamento DTO ⇄ entidade.</summary>
public sealed class [[EntityName]]Service(
    I[[EntityName]]Repository repository,
    IValidator<[[EntityName]]CreateDto> createValidator,
    IValidator<[[EntityName]]UpdateDto> updateValidator) : I[[EntityName]]Service
{
    public async Task<PagedResult<[[EntityName]]ResponseDto>> ListAsync(
        int page,
        int pageSize,
        string? sortBy,
        string? sortDir,
        string? search,
        string? filterColumn,
        string? filterValue,
        CancellationToken cancellationToken = default)
    {
        var safePage = page <= 0 ? 1 : page;
        var safePageSize = pageSize <= 0 ? 20 : pageSize;

        var (items, total) = await repository.ListAsync(
            safePage, safePageSize, sortBy, sortDir, search, filterColumn, filterValue, cancellationToken);

        return new PagedResult<[[EntityName]]ResponseDto>(
            items.Select(ToResponse).ToList(), safePage, safePageSize, total);
    }

    public async Task<[[EntityName]]ResponseDto?> GetAsync(
        [[PrimaryKeyRouteType]] id,
        CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        return entity is null ? null : ToResponse(entity);
    }

    public async Task<[[EntityName]]ResponseDto> CreateAsync(
        [[EntityName]]CreateDto dto,
        CancellationToken cancellationToken = default)
    {
        await createValidator.ValidateAndThrowAsync(dto, cancellationToken);

        var entity = new [[EntityName]]
        {
[[#each EditableFields]]            [[PropertyName]] = dto.[[PropertyName]],
[[/each]]        };

        await repository.InsertAsync(entity, cancellationToken);
        return ToResponse(entity);
    }

    public async Task<[[EntityName]]ResponseDto?> UpdateAsync(
        [[PrimaryKeyRouteType]] id,
        [[EntityName]]UpdateDto dto,
        CancellationToken cancellationToken = default)
    {
        await updateValidator.ValidateAndThrowAsync(dto, cancellationToken);

        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null)
        {
            return null;
        }

[[#each EditableFields]][[#if IsPrimaryKey]]        // O identificador é definido pela rota.
[[else]]        entity.[[PropertyName]] = dto.[[PropertyName]];
[[/if]][[/each]]
        await repository.UpdateAsync(entity, cancellationToken);
        return ToResponse(entity);
    }

    public async Task<bool> DeleteAsync([[PrimaryKeyRouteType]] id, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null)
        {
            return false;
        }

        await repository.DeleteAsync(entity, cancellationToken);
        return true;
    }

    private static [[EntityName]]ResponseDto ToResponse([[EntityName]] entity) => new()
    {
[[#each Fields]]        [[PropertyName]] = entity.[[PropertyName]],
[[/each]]    };
}
