using GeradorCodigo.Domain.Metadata;
using GeradorCodigo.Domain.ValueObjects;

namespace GeradorCodigo.Domain.Abstractions;

/// <summary>Porta responsável por converter tipos MySQL em tipos C#/TypeScript.</summary>
public interface ITypeMapper
{
    TypeMapping Map(ColumnMetadata column);
}
