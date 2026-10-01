using GeradorCodigo.Application.Dtos;
using GeradorCodigo.Application.Interfaces;

namespace GeradorCodigo.Api.Endpoints;

/// <summary>Endpoints Minimal API responsáveis pela geração de código.</summary>
public static class GenerationEndpoints
{
    public static IEndpointRouteBuilder MapGenerationEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/generation", GenerateAsync)
            .WithName("GenerateCode")
            .WithSummary("Gera Backend, API, GraphQL e Frontend para uma tabela MySQL")
            .Accepts<GenerateRequest>("application/json")
            .Produces<GenerateResponse>(StatusCodes.Status200OK)
            .Produces<GenerateResponse>(StatusCodes.Status400BadRequest)
            .Produces<GenerateResponse>(StatusCodes.Status404NotFound)
            .Produces<GenerateResponse>(StatusCodes.Status500InternalServerError);

        return app;
    }

    private static async Task<IResult> GenerateAsync(
        GenerateRequest request,
        IGenerateCodeUseCase useCase,
        CancellationToken cancellationToken)
    {
        var response = await useCase.ExecuteAsync(request, cancellationToken);
        return response switch
        {
            { RequiresConfirmation: true } => Results.Conflict(response),
            { Success: false } => Results.BadRequest(response),
            _ => Results.Ok(response),
        };
    }
}
