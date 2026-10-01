using GeradorCodigo.Domain.Abstractions;
using GeradorCodigo.Domain.Metadata;

namespace GeradorCodigo.Application.Services;

/// <summary>
/// Aciona a leitura das tabelas referenciadas por foreign keys, para que a geração
/// do formulário de FK conheça colunas de rótulo da tabela relacionada.
/// </summary>
public sealed class RelatedTableLoader
{
    private readonly IMetadataReader _metadataReader;

    public RelatedTableLoader(IMetadataReader metadataReader)
    {
        _metadataReader = metadataReader;
    }

    public async Task<IReadOnlyDictionary<string, TableMetadata>> LoadAsync(
        TableMetadata table,
        CancellationToken cancellationToken)
    {
        var relatedTableNames = table.Columns
            .SelectMany(c => c.ForeignKeys)
            .Select(fk => fk.ReferencedTable)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        var result = new Dictionary<string, TableMetadata>(StringComparer.OrdinalIgnoreCase);

        foreach (var name in relatedTableNames)
        {
            try
            {
                result[name] = await _metadataReader.ReadTableAsync(name, cancellationToken);
            }
            catch (Exception)
            {
                // Tabela relacionada ausente/inacessível: a geração continua com fallback de rótulo.
            }
        }

        return result;
    }
}
