using [[NamespaceRoot]].Application.DTOs;
using [[NamespaceRoot]].Application.Interfaces;

namespace [[NamespaceRoot]].Api.Endpoints;

/// <summary>CRUD REST de [[TableName]] — expõe somente DTOs, nunca entidades do domínio.</summary>
public static class [[EntityName]]Endpoints
{
    public static IEndpointRouteBuilder Map[[EntityName]]Endpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/[[Route]]").WithTags("[[EntityName]]");

        group.MapGet("/", ListAsync).WithName("List[[EntityName]]");
        group.MapGet("/{id}", GetAsync).WithName("Get[[EntityName]]");
        group.MapPost("/", CreateAsync).WithName("Create[[EntityName]]");
        group.MapPut("/{id}", UpdateAsync).WithName("Update[[EntityName]]");
        group.MapDelete("/{id}", DeleteAsync).WithName("Delete[[EntityName]]");

        return app;
    }

    private static async Task<IResult> ListAsync(
        I[[EntityName]]Service service,
        int page = 1,
        int pageSize = 20,
        string? sortBy = null,
        string? sortDir = null,
        string? search = null,
        string? filterColumn = null,
        string? filterValue = null,
        CancellationToken cancellationToken = default)
    {
        var result = await service.ListAsync(
            page, pageSize, sortBy, sortDir, search, filterColumn, filterValue, cancellationToken);

        return Results.Ok(result);
    }

    private static async Task<IResult> GetAsync(
        [[PrimaryKeyRouteType]] id,
        I[[EntityName]]Service service,
        CancellationToken cancellationToken = default)
    {
        var result = await service.GetAsync(id, cancellationToken);
        return result is null ? NotFound() : Results.Ok(result);
    }

    private static async Task<IResult> CreateAsync(
        [[EntityName]]CreateDto dto,
        I[[EntityName]]Service service,
        CancellationToken cancellationToken = default)
    {
        var created = await service.CreateAsync(dto, cancellationToken);
        return Results.Created($"/api/[[Route]]/{created.[[PrimaryKeyProperty]]}", created);
    }

    private static async Task<IResult> UpdateAsync(
        [[PrimaryKeyRouteType]] id,
        [[EntityName]]UpdateDto dto,
        I[[EntityName]]Service service,
        CancellationToken cancellationToken = default)
    {
        var updated = await service.UpdateAsync(id, dto, cancellationToken);
        return updated is null ? NotFound() : Results.Ok(updated);
    }

    private static async Task<IResult> DeleteAsync(
        [[PrimaryKeyRouteType]] id,
        I[[EntityName]]Service service,
        CancellationToken cancellationToken = default)
    {
        var removed = await service.DeleteAsync(id, cancellationToken);
        return removed ? Results.NoContent() : NotFound();
    }

    // Mesmo envelope de erro usado pelo middleware global de exceções.
    private static IResult NotFound() => Results.Json(
        new { success = false, message = "Registro não encontrado.", errors = Array.Empty<string>() },
        statusCode: StatusCodes.Status404NotFound);
}
