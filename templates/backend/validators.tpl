using FluentValidation;
using [[NamespaceRoot]].Application.DTOs;

namespace [[NamespaceRoot]].Application.Validators;

/// <summary>Validações geradas a partir dos metadados do banco (NOT NULL, tamanho, precisão).</summary>
public sealed class [[EntityName]]CreateValidator : AbstractValidator<[[EntityName]]CreateDto>
{
    public [[EntityName]]CreateValidator()
    {
[[#each EditableFields]]
[[#if IsRequired]][[#if IsString]]        RuleFor(x => x.[[PropertyName]])
            .NotEmpty()
            .WithMessage("[[DisplayName]] é obrigatório.");
[[/if]][[/if]]
[[#if HasMaxLength]]        RuleFor(x => x.[[PropertyName]])
            .MaximumLength([[MaxLength]])
            .WithMessage("[[DisplayName]] pode ter no máximo [[MaxLength]] caracteres.");
[[/if]]
[[#if HasPrecision]]        RuleFor(x => x.[[PropertyName]])
            .PrecisionScale([[Precision]], [[Scale]], true)
            .WithMessage("[[DisplayName]] deve respeitar [[Precision]] dígitos com [[Scale]] casas decimais.");
[[/if]]
[[/each]]    }
}

/// <summary>Validações da alteração — a chave primária é definida pela rota.</summary>
public sealed class [[EntityName]]UpdateValidator : AbstractValidator<[[EntityName]]UpdateDto>
{
    public [[EntityName]]UpdateValidator()
    {
[[#each EditableFields]]
[[#if IsRequired]][[#if IsString]]        RuleFor(x => x.[[PropertyName]])
            .NotEmpty()
            .WithMessage("[[DisplayName]] é obrigatório.");
[[/if]][[/if]]
[[#if HasMaxLength]]        RuleFor(x => x.[[PropertyName]])
            .MaximumLength([[MaxLength]])
            .WithMessage("[[DisplayName]] pode ter no máximo [[MaxLength]] caracteres.");
[[/if]]
[[#if HasPrecision]]        RuleFor(x => x.[[PropertyName]])
            .PrecisionScale([[Precision]], [[Scale]], true)
            .WithMessage("[[DisplayName]] deve respeitar [[Precision]] dígitos com [[Scale]] casas decimais.");
[[/if]]
[[/each]]    }
}
