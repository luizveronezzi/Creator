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

        // -------------------------------------------------------------- Frontend
        Add("frontend/package-json", $"Frontend/package.json");
        Add("frontend/angular-json", $"Frontend/angular.json");
        Add("frontend/tsconfig", $"Frontend/tsconfig.json");
        Add("frontend/tsconfig-app", $"Frontend/tsconfig.app.json");
        Add("frontend/index-html", $"Frontend/src/index.html");
        Add("frontend/main-ts", $"Frontend/src/main.ts");
        Add("frontend/styles-scss", $"Frontend/src/styles.scss");
        Add("frontend/app-component-ts", $"Frontend/src/app/app.component.ts");
        Add("frontend/app-component-html", $"Frontend/src/app/app.component.html");
        Add("frontend/app-component-scss", $"Frontend/src/app/app.component.scss");
        Add("frontend/app-config", $"Frontend/src/app/app.config.ts");
        Add("frontend/app-routes", $"Frontend/src/app/app.routes.ts");
        Add("frontend/proxy-conf", $"Frontend/proxy.conf.json");
        Add("frontend/theme", $"Frontend/src/app/core/theme.ts");
        Add("frontend/model", $"Frontend/src/app/{feature}/models/{feature}.model.ts");
        Add("frontend/service", $"Frontend/src/app/{feature}/services/{feature}.service.ts");
        Add("frontend/list-ts", $"Frontend/src/app/{feature}/pages/{feature}-list/{feature}-list.component.ts");
        Add("frontend/list-html", $"Frontend/src/app/{feature}/pages/{feature}-list/{feature}-list.component.html");
        Add("frontend/list-scss", $"Frontend/src/app/{feature}/pages/{feature}-list/{feature}-list.component.scss");
        Add("frontend/form-ts", $"Frontend/src/app/{feature}/pages/{feature}-form/{feature}-form.component.ts");
        Add("frontend/form-html", $"Frontend/src/app/{feature}/pages/{feature}-form/{feature}-form.component.html");
        Add("frontend/form-scss", $"Frontend/src/app/{feature}/pages/{feature}-form/{feature}-form.component.scss");

        return new FileSet(root, files);
    }
}
