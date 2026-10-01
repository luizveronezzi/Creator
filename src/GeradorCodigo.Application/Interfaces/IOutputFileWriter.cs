using GeradorCodigo.Application.Models;

namespace GeradorCodigo.Application.Interfaces;

/// <summary>
/// Porta de escrita em disco. Expõe a verificação de arquivos existentes para que
/// a confirmação de sobrescrita seja decidida pela camada de aplicação.
/// </summary>
public interface IOutputFileWriter
{
    IReadOnlyList<string> GetExistingFiles(string rootRelativePath, IEnumerable<string> relativePaths);

    /// <summary>Resolve um caminho relativo do conjunto de geração para um caminho absoluto.</summary>
    string ResolvePath(string rootRelativePath, string relativePath);

    Task WriteAsync(
        string rootRelativePath,
        IEnumerable<GeneratedFile> files,
        CancellationToken cancellationToken = default);
}
