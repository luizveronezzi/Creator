using System.Diagnostics;
using GeradorCodigo.Application.Interfaces;

namespace GeradorCodigo.Infrastructure.Generation;

/// <summary>Executa 'dotnet build' para validar a compilação do backend gerado.</summary>
public sealed class DotnetCompilationValidator : ICompilationValidator
{
    public async Task<CompilationResult> ValidateAsync(
        string solutionPath, CancellationToken cancellationToken = default)
    {
        var fullPath = Path.GetFullPath(solutionPath);
        if (!File.Exists(fullPath))
        {
            return new CompilationResult(false, $"Solução não encontrada: {fullPath}");
        }

        var startInfo = new ProcessStartInfo
        {
            FileName = "dotnet",
            Arguments = $"build \"{fullPath}\" --nologo -v minimal",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        };

        using var process = new Process { StartInfo = startInfo };
        process.Start();

        var stdout = await process.StandardOutput.ReadToEndAsync(cancellationToken);
        var stderr = await process.StandardError.ReadToEndAsync(cancellationToken);
        await process.WaitForExitAsync(cancellationToken);

        var output = string.Join(Environment.NewLine, new[] { stdout, stderr }
            .Where(part => !string.IsNullOrWhiteSpace(part)));

        return new CompilationResult(process.ExitCode == 0, output);
    }
}
