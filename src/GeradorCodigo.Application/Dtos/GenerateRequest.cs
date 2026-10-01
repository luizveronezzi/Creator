namespace GeradorCodigo.Application.Dtos;

/// <summary>Solicitação de geração de código para uma tabela.</summary>
public sealed record GenerateRequest
{
    public string TableName { get; init; } = string.Empty;

    /// <summary>Confirma a sobrescrita de arquivos já existentes.</summary>
    public bool Overwrite { get; init; }

    /// <summary>Executa um build de validação do backend gerado após a gravação.</summary>
    public bool ValidateBuild { get; init; }
}
