namespace GeradorCodigo.Application.Models;

/// <summary>Arquivo pronto para ser gravado em disco (caminho relativo + conteúdo).</summary>
public sealed record GeneratedFile(string RelativePath, string Content);

/// <summary>Conjunto de arquivos que compõem a geração de uma tabela.</summary>
public sealed record FileSet(string RootRelativePath, IReadOnlyList<GeneratedFile> Files);
