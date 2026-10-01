using FluentValidation;
using GeradorCodigo.Application.Dtos;

namespace GeradorCodigo.Application.Validators;

/// <summary>
/// Valida a solicitação de geração. O nome da tabela é a única entrada do usuário,
/// portanto é tratado como dado não confiável.
/// </summary>
public sealed class GenerateRequestValidator : AbstractValidator<GenerateRequest>
{
    private static readonly HashSet<string> ForbiddenWords = new(StringComparer.OrdinalIgnoreCase)
    {
        "information_schema", "mysql", "performance_schema", "sys",
    };

    public GenerateRequestValidator()
    {
        RuleFor(x => x.TableName)
            .NotEmpty().WithMessage("O nome da tabela é obrigatório.")
            .MaximumLength(64).WithMessage("O nome da tabela não pode exceder 64 caracteres.")
            .Matches(@"^[A-Za-z0-9_]+$")
                .WithMessage("O nome da tabela pode conter apenas letras, números e sublinhado.")
            .Must(name => !ForbiddenWords.Contains(name))
                .WithMessage("A tabela informada não pode ser acessada por este serviço.");
    }
}
