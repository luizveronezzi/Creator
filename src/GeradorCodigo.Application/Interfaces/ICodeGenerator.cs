using GeradorCodigo.Application.Models;

namespace GeradorCodigo.Application.Interfaces;

/// <summary>Responsável por montar o conjunto de arquivos (caminho + conteúdo) de uma geração.</summary>
public interface ICodeGenerator
{
    FileSet BuildFileSet(GenerationPlan plan);
}
