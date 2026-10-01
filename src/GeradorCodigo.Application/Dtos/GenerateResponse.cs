namespace GeradorCodigo.Application.Dtos;

/// <summary>Resposta padronizada de uma geração.</summary>
public sealed record GenerateResponse
{
    public required bool Success { get; init; }
    public required string Message { get; init; }
    public bool RequiresConfirmation { get; init; }
    public IReadOnlyList<string> ExistingFiles { get; init; } = [];
    public IReadOnlyList<string> GeneratedFiles { get; init; } = [];
    public string? BuildOutput { get; init; }
    public long ElapsedMilliseconds { get; init; }
}
