using GeradorCodigo.Domain.Metadata;

namespace GeradorCodigo.Domain.Abstractions;

/// <summary>Porta para leitura da estrutura de tabelas no banco de dados.</summary>
public interface IMetadataReader
{
    Task<TableMetadata> ReadTableAsync(string tableName, CancellationToken cancellationToken = default);
}
