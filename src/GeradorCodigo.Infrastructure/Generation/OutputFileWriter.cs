using System.Text;
using GeradorCodigo.Application.Interfaces;
using GeradorCodigo.Application.Models;

namespace GeradorCodigo.Infrastructure.Generation;

/// <summary>Grava os arquivos gerados no diretório de saída configurado.</summary>
public sealed class OutputFileWriter(string basePath) : IOutputFileWriter
{
    public IReadOnlyList<string> GetExistingFiles(string rootRelativePath, IEnumerable<string> relativePaths)
    {
        return relativePaths
            .Where(relative => File.Exists(Resolve(rootRelativePath, relative)))
            .ToList();
    }

    public string ResolvePath(string rootRelativePath, string relativePath) =>
        Resolve(rootRelativePath, relativePath);

    public async Task WriteAsync(
        string rootRelativePath,
        IEnumerable<GeneratedFile> files,
        CancellationToken cancellationToken = default)
    {
        foreach (var file in files)
        {
            var fullPath = Resolve(rootRelativePath, file.RelativePath);
            var directory = Path.GetDirectoryName(fullPath);
            if (!string.IsNullOrEmpty(directory))
            {
                Directory.CreateDirectory(directory);
            }

            await File.WriteAllTextAsync(fullPath, file.Content, new UTF8Encoding(false), cancellationToken);
        }
    }

    private string Resolve(string rootRelativePath, string relativePath)
    {
        var combined = Path.GetFullPath(Path.Combine(basePath, rootRelativePath, relativePath));
        var root = Path.GetFullPath(basePath);

        if (!combined.StartsWith(root, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Caminho de saída inválido: {relativePath}");
        }

        return combined;
    }
}
