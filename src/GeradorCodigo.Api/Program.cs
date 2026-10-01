using GeradorCodigo.Api.Endpoints;
using GeradorCodigo.Api.Middleware;
using GeradorCodigo.Api.Cli;
using GeradorCodigo.Infrastructure;
using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddInfrastructure(builder.Configuration, builder.Environment.ContentRootPath);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Gerador-Codigo API",
        Version = "v1",
        Description = "Gera Backend (.NET), API REST, GraphQL e Frontend (Angular) a partir da estrutura de tabelas MySQL.",
    });
});

var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("Frontend", policy =>
    policy.WithOrigins(allowedOrigins.Length > 0 ? allowedOrigins : ["http://localhost:4200"])
        .AllowAnyHeader()
        .AllowAnyMethod()));

var app = builder.Build();

// Modo linha de comando: dotnet run -- --table CUSTOMERS [--overwrite] [--build]
if (ConsoleMode.TryRun(args, app.Services))
{
    return;
}

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors("Frontend");
app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/health", () => Results.Ok(new { success = true, timestamp = DateTimeOffset.UtcNow }))
    .WithTags("Health");

app.MapGenerationEndpoints();

app.Run();
