using GeradorCodigo.Application.Dtos;
using GeradorCodigo.Application.Interfaces;

namespace GeradorCodigo.Api.Cli;

/// <summary>
/// Execução por linha de comando:
///   dotnet run -- --table CUSTOMERS [--overwrite] [--build]
/// Solicita confirmação interativamente antes de sobrescrever arquivos existentes.
/// </summary>
public static class ConsoleMode
{
    public static bool TryRun(string[] args, IServiceProvider services)
    {
        var tableName = GetOption(args, "--table");
        if (tableName is null)
        {
            return false;
        }

        var overwrite = args.Contains("--overwrite", StringComparer.OrdinalIgnoreCase);
        var request = new GenerateRequest
        {
            TableName = tableName,
            Overwrite = overwrite,
            ValidateBuild = args.Contains("--build", StringComparer.OrdinalIgnoreCase),
        };

        using var scope = services.CreateScope();
        var useCase = scope.ServiceProvider.GetRequiredService<IGenerateCodeUseCase>();

        var response = useCase.ExecuteAsync(request).GetAwaiter().GetResult();

        if (response.RequiresConfirmation)
        {
            Console.WriteLine(response.Message);
            foreach (var file in response.ExistingFiles)
            {
                Console.WriteLine($"  - {file}");
            }

            Console.Write("Deseja sobrescrever os arquivos existentes? (y/N): ");
            var answer = Console.ReadLine();
            if (!string.Equals(answer?.Trim(), "y", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("Geração cancelada. Nenhum arquivo foi alterado.");
                return true;
            }

            request = request with { Overwrite = true };
            response = useCase.ExecuteAsync(request).GetAwaiter().GetResult();
        }

        Console.WriteLine(response.Success ? $"OK: {response.Message}" : $"FALHA: {response.Message}");
        foreach (var file in response.GeneratedFiles)
        {
            Console.WriteLine($"  + {file}");
        }

        if (response.BuildOutput is not null)
        {
            Console.WriteLine(response.BuildOutput);
        }

        return true;
    }

    private static string? GetOption(string[] args, string name)
    {
        for (var i = 0; i < args.Length - 1; i++)
        {
            if (string.Equals(args[i], name, StringComparison.OrdinalIgnoreCase))
            {
                return args[i + 1];
            }
        }

        return null;
    }
}
