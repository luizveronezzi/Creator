using System.Diagnostics;
using FluentValidation;
using GeradorCodigo.Application.Dtos;
using GeradorCodigo.Application.Exceptions;
using GeradorCodigo.Application.Interfaces;
using GeradorCodigo.Application.Models;
using GeradorCodigo.Application.Services;
using GeradorCodigo.Domain.Abstractions;
using Microsoft.Extensions.Logging;

namespace GeradorCodigo.Application.UseCases;

/// <summary>
/// Orquestra o pipeline de geração:
/// ler metadados → validar → mapear tipos → identificar PK/FK → gerar backend/API/GraphQL →
/// gerar frontend → validar arquivos → exibir resultado.
/// </summary>
public sealed class GenerateCodeUseCase : IGenerateCodeUseCase
{
    private readonly IValidator<GenerateRequest> _validator;
    private readonly IMetadataReader _metadataReader;
    private readonly ITypeMapper _typeMapper;
    private readonly RelatedTableLoader _relatedTableLoader;
    private readonly ICodeGenerator _codeGenerator;
    private readonly IOutputFileWriter _fileWriter;
    private readonly ICompilationValidator _compilationValidator;
    private readonly ILogger<GenerateCodeUseCase> _logger;

    public GenerateCodeUseCase(
        IValidator<GenerateRequest> validator,
        IMetadataReader metadataReader,
        ITypeMapper typeMapper,
        RelatedTableLoader relatedTableLoader,
        ICodeGenerator codeGenerator,
        IOutputFileWriter fileWriter,
        ICompilationValidator compilationValidator,
        ILogger<GenerateCodeUseCase> logger)
    {
        _validator = validator;
        _metadataReader = metadataReader;
        _typeMapper = typeMapper;
        _relatedTableLoader = relatedTableLoader;
        _codeGenerator = codeGenerator;
        _fileWriter = fileWriter;
        _compilationValidator = compilationValidator;
        _logger = logger;
    }

    public async Task<GenerateResponse> ExecuteAsync(GenerateRequest request, CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("Iniciando geração para a tabela {Table}", request.TableName);

        await ValidateRequestAsync(request, cancellationToken);

        var table = await _metadataReader.ReadTableAsync(request.TableName, cancellationToken);
        if (table.Columns.Count == 0)
        {
            throw new GenerationException($"A tabela '{request.TableName}' não possui colunas.");
        }

        _logger.LogInformation(
            "Metadados lidos: {Columns} colunas, PK: {PrimaryKey}, FKs: {ForeignKeys}",
            table.Columns.Count,
            table.PrimaryKeyColumns.Count > 0 ? string.Join(", ", table.PrimaryKeyColumns) : "(nenhuma)",
            table.Columns.Count(c => c.ForeignKeys.Count > 0));

        var relatedTables = await _relatedTableLoader.LoadAsync(table, cancellationToken);
        var nomenclature = Nomenclature.From(table.Name);
        var plan = GenerationPlan.Create(table, relatedTables, _typeMapper.Map, nomenclature);

        var fileSet = _codeGenerator.BuildFileSet(plan);
        _logger.LogInformation(
            "{Files} arquivos planejados para a tabela {Table}",
            fileSet.Files.Count,
            table.Name);

        var existing = _fileWriter.GetExistingFiles(fileSet.RootRelativePath, fileSet.Files.Select(f => f.RelativePath));
        if (existing.Count > 0 && !request.Overwrite)
        {
            _logger.LogWarning(
                "{Count} arquivos já existem para a tabela {Table}. Aguardando confirmação de sobrescrita.",
                existing.Count,
                table.Name);

            return new GenerateResponse
            {
                Success = false,
                RequiresConfirmation = true,
                ExistingFiles = existing,
                Message = $"A pasta da tabela '{table.Name}' já contém {existing.Count} arquivo(s). " +
                          "Reenvie com overwrite = true para confirmar a sobrescrita.",
                ElapsedMilliseconds = stopwatch.ElapsedMilliseconds,
            };
        }

        await _fileWriter.WriteAsync(fileSet.RootRelativePath, fileSet.Files, cancellationToken);

        var written = _fileWriter.GetExistingFiles(
            fileSet.RootRelativePath,
            fileSet.Files.Select(f => f.RelativePath));

        if (written.Count != fileSet.Files.Count)
        {
            var missing = fileSet.Files.Count - written.Count;
            throw new GenerationException($"Falha ao gravar arquivos: {missing} arquivo(s) ausentes após a escrita.");
        }

        foreach (var group in fileSet.Files.GroupBy(f => f.RelativePath.Split('/')[0]))
        {
            _logger.LogInformation("Arquivos gerados em {Folder}: {Count}", group.Key, group.Count());
        }

        string? buildOutput = null;
        if (request.ValidateBuild)
        {
            var solutionPath = _fileWriter.ResolvePath(
                fileSet.RootRelativePath,
                Path.Combine("Backend", plan.SolutionFileName));

            _logger.LogInformation("Validando compilação do backend gerado: {Solution}", solutionPath);
            var compilation = await _compilationValidator.ValidateAsync(solutionPath, cancellationToken);
            if (!compilation.Success)
            {
                throw new GenerationException(
                    $"O backend gerado não compilou:{Environment.NewLine}{compilation.Output}");
            }

            buildOutput = compilation.Output;
        }

        stopwatch.Stop();
        _logger.LogInformation(
            "Geração concluída para {Table} em {Elapsed} ms ({Files} arquivos)",
            table.Name,
            stopwatch.ElapsedMilliseconds,
            written.Count);

        return new GenerateResponse
        {
            Success = true,
            Message = $"Geração concluída para a tabela '{table.Name}' com {written.Count} arquivo(s).",
            GeneratedFiles = written,
            BuildOutput = buildOutput,
            ElapsedMilliseconds = stopwatch.ElapsedMilliseconds,
        };
    }

    private async Task ValidateRequestAsync(GenerateRequest request, CancellationToken cancellationToken)
    {
        var result = await _validator.ValidateAsync(request, cancellationToken);
        if (!result.IsValid)
        {
            throw new RequestValidationException(result.Errors.Select(e => e.ErrorMessage).ToList());
        }
    }
}
