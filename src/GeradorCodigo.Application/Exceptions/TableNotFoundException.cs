namespace GeradorCodigo.Application.Exceptions;

/// <summary>A tabela informada não existe ou não é acessível.</summary>
public sealed class TableNotFoundException(string tableName)
    : Exception($"A tabela '{tableName}' não foi encontrada ou não é acessível.");
