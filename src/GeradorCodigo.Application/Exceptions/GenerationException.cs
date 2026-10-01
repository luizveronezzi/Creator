namespace GeradorCodigo.Application.Exceptions;

/// <summary>Falha de regra durante o processo de geração.</summary>
public sealed class GenerationException(string message) : Exception(message);
