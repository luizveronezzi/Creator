namespace GeradorCodigo.Application.Exceptions;

/// <summary>Falha de validação das entradas do caso de uso.</summary>
public sealed class RequestValidationException(IReadOnlyList<string> errors)
    : Exception(string.Join(Environment.NewLine, errors))
{
    public IReadOnlyList<string> Errors { get; } = errors;
}
