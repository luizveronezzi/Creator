using System.Text.Json;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace [[NamespaceRoot]].Api.Middleware;

/// <summary>Trata exceções globalmente e padroniza as respostas de erro da API.</summary>
public sealed class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception exception)
        {
            await HandleAsync(context, exception);
        }
    }

    private async Task HandleAsync(HttpContext context, Exception exception)
    {
        var (statusCode, message, errors) = Map(exception);

        if (statusCode >= 500)
        {
            logger.LogError(exception, "Erro não tratado ao processar {Method} {Path}",
                context.Request.Method, context.Request.Path);
        }
        else
        {
            logger.LogWarning(exception, "Solicitação rejeitada com {Status} em {Path}",
                statusCode, context.Request.Path);
        }

        if (context.Response.HasStarted)
        {
            return;
        }

        context.Response.Clear();
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        await context.Response.WriteAsync(JsonSerializer.Serialize(
            new { success = false, message, errors }, JsonOptions));
    }

    private static (int StatusCode, string Message, IReadOnlyList<string> Errors) Map(Exception exception) =>
        exception switch
        {
            ValidationException validation => (
                StatusCodes.Status400BadRequest,
                "Falha na validação do registro.",
                validation.Errors.Select(error => error.ErrorMessage).ToArray()),
            BadHttpRequestException badRequest => (
                StatusCodes.Status400BadRequest,
                "Requisição inválida.",
                [badRequest.Message]),
            DbUpdateConcurrencyException => (
                StatusCodes.Status409Conflict,
                "O registro não existe mais ou foi modificado por outra operação.",
                Array.Empty<string>()),
            OperationCanceledException => (
                499,
                "Solicitação cancelada.",
                Array.Empty<string>()),
            _ => (
                StatusCodes.Status500InternalServerError,
                "Erro ao processar a solicitação.",
                Array.Empty<string>()),
        };
}
