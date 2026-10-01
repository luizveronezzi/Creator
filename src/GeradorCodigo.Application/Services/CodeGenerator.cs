using GeradorCodigo.Application.Interfaces;
using GeradorCodigo.Application.Models;

namespace GeradorCodigo.Application.Services;

/// <summary>
/// Monta o conjunto de arquivos (caminhos + conteúdo renderizado) para uma tabela.
/// A composição dos caminhos é responsabilidade desta classe; a renderização é
/// delegada ao ITemplateEngine e a gravação ao IOutputFileWriter.
/// </summary>
public sealed class CodeGenerator(ITemplateEngine templateEngine) : ICodeGenerator
{
    public FileSet BuildFileSet(GenerationPlan plan)
    {
        var root = plan.TableName;
        var prefix = plan.ProjectPrefix;
        var feature = plan.FeatureName;
        var files = new List<GeneratedFile>();

        void Add(string template, string relativePath) =>
            files.Add(new GeneratedFile(relativePath, templateEngine.Render(template, plan)));

        // ---------------------------------------------------------------- Backend
        Add("backend/solution", $"Backend/{plan.SolutionFileName}");

        Add("backend/domain-csproj", $"Backend/{prefix}.Domain/{prefix}.Domain.csproj");
        Add("backend/entity", $"Backend/{prefix}.Domain/Entities/{plan.EntityName}.cs");

        Add("backend/application-csproj", $"Backend/{prefix}.Application/{prefix}.Application.csproj");
        Add("backend/paged-result", $"Backend/{prefix}.Application/Common/PagedResult.cs");
        Add("backend/dtos", $"Backend/{prefix}.Application/DTOs/{plan.EntityName}Dtos.cs");
        Add("backend/repository-interface", $"Backend/{prefix}.Application/Interfaces/I{plan.EntityName}Repository.cs");
        Add("backend/service-interface", $"Backend/{prefix}.Application/Interfaces/I{plan.EntityName}Service.cs");
        Add("backend/service", $"Backend/{prefix}.Application/Services/{plan.EntityName}Service.cs");
        Add("backend/validators", $"Backend/{prefix}.Application/Validators/{plan.EntityName}Validators.cs");

        Add("backend/infrastructure-csproj", $"Backend/{prefix}.Infrastructure/{prefix}.Infrastructure.csproj");
        Add("backend/dbcontext", $"Backend/{prefix}.Infrastructure/Persistence/{prefix}ModuleDbContext.cs");
        Add("backend/entity-configuration", $"Backend/{prefix}.Infrastructure/Persistence/Configurations/{plan.EntityName}Configuration.cs");
        Add("backend/repository", $"Backend/{prefix}.Infrastructure/Repositories/{plan.EntityName}Repository.cs");

        Add("backend/api-csproj", $"Backend/{prefix}.Api/{prefix}.Api.csproj");
        Add("backend/launchsettings", $"Backend/{prefix}.Api/Properties/launchSettings.json");
        Add("backend/api-program", $"Backend/{prefix}.Api/Program.cs");
        Add("backend/appsettings", $"Backend/{prefix}.Api/appsettings.json");
        Add("backend/exception-middleware", $"Backend/{prefix}.Api/Middleware/ExceptionHandlingMiddleware.cs");
        Add("backend/endpoints", $"Backend/{prefix}.Api/Endpoints/{plan.EntityName}Endpoints.cs");
        Add("backend/graphql-query", $"Backend/{prefix}.Api/GraphQL/{plan.EntityName}Query.cs");

        // -------------------------------------------------------------- Frontend (sakai-ng compatible)
        // Gera apenas arquivos de feature para integração com o projeto sakai-ng existente
        // Estrutura: src/app/pages/{feature}/{feature}.ts (crud-style component)
        //            src/app/pages/{feature}/{feature}.html (template)
        //            src/app/pages/{feature}/{feature}.scss (styles)
        //            src/app/pages/{feature}/{feature}.routes.ts (lazy-loaded routes)
        //            src/app/pages/{feature}/models/{feature}.model.ts
        //            src/app/pages/{feature}/services/{feature}.service.ts

        var featurePath = $"src/app/pages/{feature}";

        Add("frontend/sakai-model", $"{featurePath}/models/{feature}.model.ts");
        Add("frontend/sakai-service", $"{featurePath}/services/{feature}.service.ts");
        Add("frontend/sakai-crud-ts", $"{featurePath}/{feature}.ts");
        Add("frontend/sakai-crud-html", $"{featurePath}/{feature}.html");
        Add("frontend/sakai-crud-scss", $"{featurePath}/{feature}.scss");
        Add("frontend/sakai-crud-routes", $"{featurePath}/{feature}.routes.ts");

        return new FileSet(root, files);
    }
}
