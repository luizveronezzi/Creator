using FluentValidation;
using [[NamespaceRoot]].Api.Endpoints;
using [[NamespaceRoot]].Api.GraphQL;
using [[NamespaceRoot]].Api.Middleware;
using [[NamespaceRoot]].Application.DTOs;
using [[NamespaceRoot]].Application.Interfaces;
using [[NamespaceRoot]].Application.Services;
using [[NamespaceRoot]].Application.Validators;
using [[NamespaceRoot]].Infrastructure.Persistence;
using [[NamespaceRoot]].Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);

// A connection string nunca fica hardcoded: use appsettings.json ou
// a variável de ambiente ConnectionStrings__MySql.
var connectionString = builder.Configuration.GetConnectionString("MySql");
if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "Connection string 'MySql' não configurada. " +
        "Defina ConnectionStrings__MySql (variável de ambiente) ou preencha appsettings.json.");
}

var serverVersion = ServerVersion.Parse(
    builder.Configuration["MySql:ServerVersion"] ?? "8.0.36-mysql");

builder.Services.AddDbContext<[[NamespaceRoot]]DbContext>(options =>
    options.UseMySql(connectionString, serverVersion));

builder.Services.AddScoped<I[[EntityName]]Repository, [[EntityName]]Repository>();
builder.Services.AddScoped<I[[EntityName]]Service, [[EntityName]]Service>();
builder.Services.AddScoped<IValidator<[[EntityName]]CreateDto>, [[EntityName]]CreateValidator>();
builder.Services.AddScoped<IValidator<[[EntityName]]UpdateDto>, [[EntityName]]UpdateValidator>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "[[NamespaceRoot]] API",
        Version = "v1",
        Description = "CRUD gerado automaticamente a partir da tabela [[TableName]].",
    });
});

var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("Frontend", policy =>
    policy.WithOrigins(allowedOrigins.Length > 0 ? allowedOrigins : ["http://localhost:4200"])
        .AllowAnyHeader()
        .AllowAnyMethod()));

builder.Services
    .AddGraphQLServer()
    .AddQueryType<[[EntityName]]Query>();

var app = builder.Build();

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors("Frontend");
app.UseSwagger();
app.UseSwaggerUI();

app.Map[[EntityName]]Endpoints();
app.MapGraphQL("/graphql");

app.Run();
