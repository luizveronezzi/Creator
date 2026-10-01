namespace GeradorCodigo.Application.Interfaces;

/// <summary>Resultado da validação de compilação do backend gerado.</summary>
public sealed record CompilationResult(bool Success, string Output);

/// <summary>Valida a compilação do backend gerado (execução opcional de dotnet build).</summary>
public interface ICompilationValidator
{
    Task<CompilationResult> ValidateAsync(string solutionPath, CancellationToken cancellationToken = default);
}
