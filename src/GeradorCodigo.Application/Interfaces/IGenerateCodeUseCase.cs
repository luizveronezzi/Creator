using GeradorCodigo.Application.Dtos;
using GeradorCodigo.Application.Models;

namespace GeradorCodigo.Application.Interfaces;

/// <summary>Contrato do caso de uso de geração de código.</summary>
public interface IGenerateCodeUseCase
{
    Task<GenerateResponse> ExecuteAsync(GenerateRequest request, CancellationToken cancellationToken = default);
}
