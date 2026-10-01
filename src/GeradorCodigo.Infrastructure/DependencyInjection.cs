using FluentValidation;
using GeradorCodigo.Application.Dtos;
using GeradorCodigo.Application.Interfaces;
using GeradorCodigo.Application.Services;
using GeradorCodigo.Application.UseCases;
using GeradorCodigo.Application.Validators;
using GeradorCodigo.Domain.Abstractions;
using GeradorCodigo.Infrastructure.Generation;
using GeradorCodigo.Infrastructure.Persistence;
using GeradorCodigo.Infrastructure.Mappers;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace GeradorCodigo.Infrastructure;

/// <summary>Registro das implementações da camada de infraestrutura.</summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration,
        string contentRootPath)
    {
        var repositoryRoot = FindRepositoryRoot(contentRootPath);

        var outputRoot = configuration["Generation:OutputRoot"] ?? "Generated";
        var outputPath = Path.IsPathRooted(outputRoot)
            ? outputRoot
            : Path.Combine(repositoryRoot, outputRoot);

        var templatesPath = configuration["Generation:TemplatesPath"] ?? "templates";
        var templatesDirectory = Path.IsPathRooted(templatesPath)
            ? templatesPath
            : FirstExisting(
                Path.Combine(repositoryRoot, templatesPath),
                Path.Combine(contentRootPath, templatesPath),
                Path.Combine(AppContext.BaseDirectory, templatesPath));

        services.AddSingleton<IMetadataReader, MySqlMetadataReader>();
        services.AddSingleton<ITypeMapper, MySqlTypeMapper>();
        services.AddSingleton<ITemplateEngine>(_ => new TemplateEngine(templatesDirectory));
        services.AddSingleton<IOutputFileWriter>(_ => new OutputFileWriter(outputPath));
        services.AddSingleton<ICompilationValidator, DotnetCompilationValidator>();

        services.AddScoped<RelatedTableLoader>();
        services.AddScoped<ICodeGenerator, CodeGenerator>();
        services.AddScoped<IValidator<GenerateRequest>, GenerateRequestValidator>();
        services.AddScoped<IGenerateCodeUseCase, GenerateCodeUseCase>();

        return services;
    }

    private static string FirstExisting(params string[] candidates)
    {
        return candidates.FirstOrDefault(Directory.Exists) ?? candidates[0];
    }

    /// <summary>
    /// Sobe a árvore de diretórios até encontrar a raiz da solução (.sln/.slnx/.git),
    /// garantindo que a saída seja ./Generated na raiz do repositório, independentemente
    /// do diretório de conteúdo usado pelo dotnet run.
    /// </summary>
    private static string FindRepositoryRoot(string startPath)
    {
        var current = new DirectoryInfo(startPath);

        while (current is not null)
        {
            var hasSolution = current.EnumerateFiles("*.sln").Any()
                              || current.EnumerateFiles("*.slnx").Any()
                              || Directory.Exists(Path.Combine(current.FullName, ".git"));
            if (hasSolution)
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        return startPath;
    }
}
