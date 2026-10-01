# Gerador-Codigo

Aplicação geradora de código: recebe o **nome de uma tabela MySQL**, lê seus metadados reais no
`INFORMATION_SCHEMA` e **gera fisicamente** um Backend .NET completo (Clean Architecture + Minimal API
+ CRUD REST + GraphQL + EF Core + FluentValidation + Swagger) e um Frontend Angular (Standalone
Components + Reactive Forms + Signals + PrimeNG/Sakai), prontos para compilar e executar.

- Geração **100% baseada em metadados** (PK, FK, auto_increment, nullable, tipos, índices,
  comentários) — funciona para qualquer tabela sem alterar o código-fonte do gerador.
- **Nunca sobrescreve** arquivos existentes sem confirmação explícita.
- Nenhuma credencial hardcoded: connection string por `appsettings.json` ou variável de ambiente.

---

## 1. Requisitos

| Item | Versão testada | Observação |
|---|---|---|
| .NET SDK | 10.0.401 (LTS) | Backend do gerador e backends gerados (`net10.0`) |
| MySQL / MariaDB | MariaDB 11.3 (porta 3306) | Compatível com MySQL 8+ (driver MySqlConnector) |
| Node.js + npm | Node 24.21 / npm 11.3 | Frontend gerado (Angular 20 LTS) |

---

## 2. Instalação

```powershell
# 1) Restaura e compila a solução do gerador (deve compilar com 0 erros / 0 avisos)
dotnet build GeradorCodigo.sln

# 2) Dependências do frontend gerado (executar dentro da pasta do frontend gerado)
cd Generated\customers\Frontend
npm install
```

---

## 3. Configuração do MySQL

Crie o banco e (para um teste completo) as tabelas de exemplo usadas neste projeto:

```sql
CREATE DATABASE IF NOT EXISTS base DEFAULT CHARSET utf8mb4;

CREATE TABLE `countries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` char(2) NOT NULL,
  `name` varchar(80) NOT NULL,
  `active` bit(1) NOT NULL DEFAULT b'1',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_countries_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Países de referência';

CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Nome completo do cliente',
  `email` varchar(150) NOT NULL COMMENT 'E-mail principal',
  `notes` text DEFAULT NULL COMMENT 'Observações livres',
  `credit_limit` decimal(10,2) DEFAULT NULL,
  `country_id` int NOT NULL,
  `status` enum('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE' COMMENT 'Situação cadastral',
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `birth_date` date DEFAULT NULL,
  `last_purchase_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_customers_email` (`email`),
  KEY `ix_customers_name` (`name`),
  KEY `fk_customers_country` (`country_id`),
  CONSTRAINT `fk_customers_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Cadastro de clientes';
```

Essas tabelas exercitam todos os cenários: auto_increment, PK, FK, enum, bit, decimal(10,2), date,
datetime, text, índices únicos/normais e comentários de coluna/tabela (que viram mensagens de
validação e rótulos da UI).

---

## 4. Connection string

Nunca fica hardcoded. Duas formas (a variável de ambiente tem precedência sobre o JSON):

**Variável de ambiente (recomendado):**

```powershell
# PowerShell
$env:ConnectionStrings__MySql = "Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"
```

```bash
# Linux/macOS
export ConnectionStrings__MySql="Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"
```

**Ou** preencha `src/GeradorCodigo.Api/appsettings.json` / o `appsettings.json` da API gerada:

```json
{
  "ConnectionStrings": {
    "MySql": "Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"
  }
}
```

Se ausente, a aplicação falha no startup com mensagem explicando como configurar.

---

## 5. Execução do projeto (o gerador)

### 5.1 Modo API (servidor)

```powershell
$env:ConnectionStrings__MySql = "Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"
dotnet run --project src/GeradorCodigo.Api --launch-profile http
```

- Base: **http://localhost:5080**
- Swagger: **http://localhost:5080/swagger**
- Health: **http://localhost:5080/health**
- Endpoint de geração: `POST /api/generation`

### 5.2 Modo CLI (linha de comando)

```powershell
$env:ConnectionStrings__MySql = "Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"

# Gerar (tabela inédita)
dotnet run --project src/GeradorCodigo.Api --no-launch-profile -- --table customers

# Gerar com validação de compilação do backend gerado
dotnet run --project src/GeradorCodigo.Api --no-launch-profile -- --table customers --build

# Regenerar tabela já existente (pergunta y/N antes de sobrescrever)
dotnet run --project src/GeradorCodigo.Api --no-launch-profile -- --table customers

# Regenerar sem perguntar (uso em CI)
dotnet run --project src/GeradorCodigo.Api --no-launch-profile -- --table customers --overwrite --build
```

Flags: `--table <nome>` (obrigatório para o modo CLI), `--overwrite` (não pergunta), `--build`
(roda `dotnet build` na solução gerada).

---

## 6. Geração de código via API HTTP

### 6.1 Gerar uma tabela nova

```powershell
curl -X POST http://localhost:5080/api/generation `
  -H "Content-Type: application/json" `
  -d '{"tableName":"customers","overwrite":false,"validateBuild":true}'
```

Resposta `200`:

```json
{
  "success": true,
  "message": "Geração concluída para a tabela 'customers' com 43 arquivo(s).",
  "requiresConfirmation": false,
  "existingFiles": [],
  "generatedFiles": ["Backend/Customer.sln", "Backend/Customer.Domain/Customer.Domain.csproj", "..."],
  "buildOutput": "... 0 Aviso(s), 0 Erro(s) ...",
  "elapsedMilliseconds": 4771
}
```

### 6.2 Sobrescrita de tabela já existente (nunca silenciosa)

Sem `overwrite`, a API **não grava nada** e responde `409 Conflict` com a lista dos arquivos que
seriam tocados:

```json
{
  "success": false,
  "message": "A pasta da tabela 'customers' já contém 43 arquivo(s). Reenvie com overwrite = true para confirmar a sobrescrita.",
  "requiresConfirmation": true,
  "existingFiles": ["Backend/Customer.sln", "..."],
  "generatedFiles": []
}
```

Reenvie com `"overwrite": true` para confirmar.

### 6.3 Erros padronizados

```json
// 400 — validação da requisição
{ "success": false, "message": "Falha na solicitação.", "errors": ["O nome da tabela é obrigatório."] }

// 404 — tabela inexistente
{ "success": false, "message": "A tabela 'x' não foi encontrada ou não é acessível.", "errors": [] }
```

---

## 7. Estrutura das pastas

### 7.1 Projeto do gerador

```
Creator/
├── GeradorCodigo.sln                  # Solução (formato clássico .sln)
├── README.md
├── projeto.md                          # Especificação
├── .gitignore
├── src/
│   ├── GeradorCodigo.Domain/           # Metadados, portas (IMetadataReader/ITypeMapper), TypeMapping
│   │   ├── Metadata/                   # TableMetadata, ColumnMetadata, ForeignKeyMetadata, IndexMetadata
│   │   ├── Abstractions/
│   │   └── ValueObjects/
│   ├── GeradorCodigo.Application/      # Use case, DTOs, validators, planos de geração
│   │   ├── UseCases/GenerateCodeUseCase.cs
│   │   ├── Services/CodeGenerator.cs   # mapa template → caminho de saída
│   │   ├── Models/                     # GenerationPlan, FieldPlan, Nomenclature, IndexPlan
│   │   ├── Dtos/  Exceptions/  Interfaces/  Validators/
│   ├── GeradorCodigo.Infrastructure/   # Implementações
│   │   ├── Persistence/MySqlMetadataReader.cs   # INFORMATION_SCHEMA parametrizado
│   │   ├── Generation/TemplateEngine.cs         # engine [[...]] recursivo
│   │   ├── Generation/OutputFileWriter.cs       # gravação + detecção de sobrescrita
│   │   ├── Generation/DotnetCompilationValidator.cs
│   │   ├── Mappers/MySqlTypeMapper.cs           # MySQL → C#/TypeScript
│   │   ├── TypeMapping/
│   │   └── DependencyInjection.cs               # resolve raiz do repositório (.sln/.git)
│   └── GeradorCodigo.Api/              # Host + entrada única
│       ├── Program.cs                  # servidor (Swagger, CORS, /health, POST /api/generation)
│       ├── Cli/ConsoleMode.cs          # modo --table/--overwrite/--build
│       ├── Endpoints/  Middleware/
└── templates/                          # 43 templates = 43 arquivos gerados
    ├── backend/  (21 .tpl)             # solution, csprojs, entity, dtos, repos, services,
    │                                   # validators, dbcontext, config, endpoints, graphql,
    │                                   # middleware, program, appsettings, launchsettings
    └── frontend/ (22 .tpl)             # package.json, angular.json, tsconfigs, app shell,
                                        # theme, model, service, list/form (ts/html/scss), proxy
```

### 7.2 Código gerado

```
Generated/
├── customers/                          # uma pasta por tabela (lowercase)
│   ├── Backend/
│   │   ├── Customer.sln
│   │   ├── Customer.Domain/            # Entities/Customer.cs
│   │   ├── Customer.Application/       # DTOs, Interfaces, Services, Validators, Common
│   │   ├── Customer.Infrastructure/    # Persistence (DbContext + Configuration), Repositories
│   │   └── Customer.Api/               # Program, Endpoints, GraphQL, Middleware, Properties
│   └── Frontend/
│       ├── package.json  angular.json  tsconfig*.json  proxy.conf.json
│       └── src/app/
│           ├── app.component.*  app.config.ts  app.routes.ts  core/theme.ts
│           └── customers/
│               ├── models/customers.model.ts
│               ├── services/customers.service.ts
│               └── pages/
│                   ├── customers-list/   # tabela PrimeNG: paginação, busca, ordenação, CRUD
│                   └── customers-form/   # Reactive Form gerado pelos metadados
└── countries/                          # segunda tabela — mesma estrutura
```

---

## 8. Uso da API REST gerada

Suba a API gerada (ela usa a porta **5081** por `launchSettings.json`):

```powershell
$env:ConnectionStrings__MySql = "Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"
dotnet run --project Generated/customers/Backend/Customer.Api
# Swagger: http://localhost:5081/swagger
```

### Endpoints (gerados para cada tabela)

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/customers` | Lista paginada (paginação, busca, ordenação, filtro) |
| GET | `/api/customers/{id}` | Detalhe |
| POST | `/api/customers` | Criação |
| PUT | `/api/customers/{id}` | Atualização |
| DELETE | `/api/customers/{id}` | Exclusão |

### Exemplos

```powershell
# Lista com paginação/busca/ordenação
curl "http://localhost:5081/api/customers?page=1&pageSize=5&search=ana&sortBy=name&sortDir=asc"
# 200 → { "items":[...], "page":1, "pageSize":5, "totalCount":1, "totalPages":1 }

# Detalhe
curl http://localhost:5081/api/customers/1

# Criação (comentários das colunas viram mensagens de validação)
curl -X POST http://localhost:5081/api/customers -H "Content-Type: application/json" -d '{
  "name":"Maria Silva","email":"maria@example.com","creditLimit":1234.56,
  "countryId":1,"status":"ACTIVE","isActive":true,"birthDate":"1992-03-15"
}'
# 201 → { "id":5, "name":"Maria Silva", ... }

# Inválido → envelope padronizado
curl -X POST http://localhost:5081/api/customers -H "Content-Type: application/json" -d '{"email":"x"}'
# 400 → { "success":false, "message":"Falha na validação do registro.",
#        "errors":["Nome completo do cliente é obrigatório.","Situação cadastral é obrigatório."] }

# Atualização / exclusão / não encontrado
curl -X PUT    http://localhost:5081/api/customers/5 -H "Content-Type: application/json" -d '{...}'   # 200
curl -X DELETE http://localhost:5081/api/customers/5                                                   # 204
curl http://localhost:5081/api/customers/99999
# 404 → { "success":false, "message":"Registro não encontrado.", "errors":[] }
```

Tratamento global de exceções (`ExceptionHandlingMiddleware`): validação → `400` com a lista de
erros; registro inexistente → `404` com envelope; conflito de concorrência → `409`; inesperado →
`500` com envelope (sem vazar stack trace no corpo).

---

## 9. Uso do GraphQL gerado

Endpoint: **`POST /graphql`** (mesmas camadas Application/Infrastructure da REST — sem acesso
direto ao banco).

```powershell
curl -X POST http://localhost:5081/graphql -H "Content-Type: application/json" -d '{
  "query": "{ customers(page:1, pageSize:10, search:\"ana\") { items { id name email creditLimit status isActive birthDate } page totalCount totalPages } }"
}'
```

```json
{ "data": { "customers": { "items": [ { "id": 1, "name": "Ana Silva", "...": "..." } ],
  "page": 1, "totalCount": 2, "totalPages": 1 } } }
```

Consulta pontual:

```graphql
query {
  customer(id: 1) { id name email status }
}
```

Queries expostas: `customers(page, pageSize, sortBy, sortDir, search)` (paginação) e `customer(id)`.

---

## 10. Execução do Angular gerado

```powershell
cd Generated/customers/Frontend

npm install        # uma vez
npm start          # ng serve + proxy → http://localhost:5081  (http://localhost:4200)
npm run build      # build de produção (validado: 0 erros / 0 avisos)
```

- **http://localhost:4200/customers** — listagem (tabela PrimeNG, paginação, busca, ordenação,
  botões Novo/Editar/Excluir com confirmação, loading, toast de erros, estado vazio)
- **http://localhost:4200/customers/new** — formulário de inclusão
- **http://localhost:4200/customers/{id}** — formulário de alteração

O `proxy.conf.json` encaminha `/api` e `/graphql` para a API gerada (porta 5081), evitando CORS
em desenvolvimento (a API também libera `http://localhost:4200` via `Cors:AllowedOrigins`).

Formulário gerado pelos metadados: `VARCHAR/CHAR` → InputText, `TEXT` → Textarea, `INT/DECIMAL` →
InputNumber, `DATE` → DatePicker, `DATETIME` → DateTimePicker, `BIT/BOOLEAN` → Checkbox, `ENUM` →
Select (valores do banco), FK → Select carregado da API da tabela referenciada; `auto_increment`
nasce desabilitado. Validações (obrigatório, `maxlength`, precisão/escala) são geradas também no
FluentValidation do backend.

---

## 11. Decisões técnicas

1. **.NET 10 LTS + Minimal API** sem Controllers MVC; **Angular 20 LTS** com Standalone Components
   e Signals.
2. **Template engine próprio com delimitador `[[...]]`** (evita colisão com a interpolação `{{ }}`
   do Angular), com `[[#each]]`, `[[#if]]/[[else]]` aninháveis, `[[.]]`/`[[.prop]]`, e suporte a
   colchete literal imediatamente antes de uma tag (ex.: `= [[[#each ...]]]`). Todo o código gerado
   vem de `templates/*.tpl` — nenhuma string grande dentro das classes.
3. **Namespace raiz `{Entity}Module`** (ex.: `CustomerModule`) para evitar a colisão clássica
   entre a classe `Customer` e o namespace `Customer.*`.
4. **EF Core 9.0.20 + Pomelo 9.0.0** rodando em `net10.0`: o provider Pomelo não publicou release
   para EF Core 10; a combinação é compatível e mantém o LTS do runtime.
5. **HotChocolate 16** com `AddGraphQLServer()` (o `AddGraphQL()` puro não registra
   `IHttpRequestInterceptor` do ASP.NET Core e falhava em runtime).
6. **FluentValidation 12**: `PrecisionScale(precision, scale, ignoreTrailingZeros)` — assinatura
   com precisão primeiro (`DECIMAL(10,2)` → `PrecisionScale(10, 2, true)`).
7. **Nomenclatura por heurística de singularização em inglês** (`customers` → `Customer`,
   `countries` → `Country`; regras: `ies→y`, `ss/us/is` preserva, `ses/xes/zes/ches/shes→-es`,
   `s→-s`). `EntityName`/projetos são singulares; `FeatureName`/`Route` são plurais em snake_case
   (`/api/countries`), inclusive para rotas de FK.
8. **Tabela sem chave primária**: usa a primeira coluna como identificador (documentado; aviso no
   log). Leitura de tabela é case-insensitive (compatível com `lower_case_table_names` do MariaDB).
9. **Saída em `Generated/<tabela>`** na raiz do repositório — a raiz é encontrada subindo a árvore
   até achar `.sln`/`.slnx`/`.git`.
10. **Solução em formato clássico `.sln`** (tanto a do gerador quanto as geradas), conforme a
    entrega pedida.
11. **Portas**: gerador `5080`, APIs geradas `5081` (via `launchSettings.json` gerado), Angular
    `4200` — sem conflito quando tudo roda junto.
12. **Versões do frontend fixadas em exatas** (`20.3.31` etc.): o Angular 20 exige peers exatas
    entre pacotes (`@angular/forms` → `@angular/common@20.3.31`); ranges soltos quebram o
    `npm install`. `@angular/cdk` fica em `20.2.14` (última da major 20) por exigência do
    PrimeNG.
13. **PrimeNG 20 com preset custom `SakaiTheme`** (azul Sakai sobre Aura), registrado em
    `providePrimeNG` — mesma base visual do template Sakai.
14. **Estrutura feature** `models/ + services/ + pages/` (a pasta `components/` da spec é
    representada por `pages/`, que contém os componentes list/form).
15. **Sobrescrita sempre confirmada**: API responde `409` + `existingFiles` (reenviar com
    `overwrite=true`); CLI pergunta `y/N`; flag `--overwrite` para automação.
16. **Validação de compilação opcional** (`--build` / `validateBuild`) executa `dotnet build` na
    solução gerada e devolve a saída no resultado.
17. **Envelope de erro único** `{success:false, message, errors:[]}` para todas as falhas, gerado
    pelo middleware global (tanto do gerador quanto das APIs geradas).

---

## 12. Validação executada (critérios de aceitação)

| # | Critério | Status | Como foi validado |
|---|---|---|---|
| 1 | Aplicação inicia sem erros | ✅ | `dotnet run` (servidor e CLI) sem exceções |
| 2 | Conecta ao MySQL | ✅ | Leitura do `INFORMATION_SCHEMA` (MariaDB 11.3) |
| 3 | Recebe o nome de uma tabela | ✅ | `--table customers`, `POST /api/generation` |
| 4 | Lê metadados | ✅ | 11 colunas (customers) / 5 (countries): tipos, índices, comentários, defaults |
| 5 | Identifica PK | ✅ | Log `PK: id`; FKs: `fk_customers_country → countries(id)` |
| 6 | Identifica tipos e nullable | ✅ | `int → int`, `varchar(100) → string`, `date → DateOnly`, `bit → bool`, `decimal?`, etc. |
| 7 | Identifica auto_increment | ✅ | Entity `ValueGeneratedOnAdd`, form `{value:null, disabled:true}` |
| 8 | Gera Backend | ✅ | 4 projetos + `.sln` em `Generated/<tabela>/Backend` |
| 9 | Gera CRUD REST | ✅ | GET/GET id/POST(201)/PUT(200)/DELETE(204)/404 envelope testados |
| 10 | Gera GraphQL | ✅ | `POST /graphql` → `200` com `customers`/`customer` |
| 11 | Gera Frontend Angular | ✅ | `npm install` + `npm run build` → **0 erros / 0 avisos** |
| 12 | Gera Tela de listagem | ✅ | Tabela PrimeNG com paginação/busca/ordenação/confirmação |
| 13 | Gera Formulário | ✅ | Reactive Form com InputText/InputNumber/DatePicker/Checkbox/Select por tipo |
| 14 | Gera validações | ✅ | FluentValidation + validators do form (mensagens vindas dos comentários) |
| 15 | Compila o código gerado | ✅ | `dotnet build` das duas soluções geradas: **0 erros / 0 avisos** |
| 16 | Não sobrescreve sem confirmação | ✅ | API `409` + lista; CLI `y/N`; `--overwrite` explícito |

---

## 13. Passo a passo rápido (do zero ao CRUD completo)

```powershell
# 0) Pré-requisitos: .NET 10 SDK, MySQL/MariaDB, Node 20+ — e a connection string (seção 4)
$env:ConnectionStrings__MySql = "Server=localhost;Port=3306;Database=base;User ID=admin;Password=admin1234"

# 1) Compila o gerador
dotnet build GeradorCodigo.sln

# 2) Gera Backend + Frontend de customers (com build de validação)
dotnet run --project src/GeradorCodigo.Api --no-launch-profile -- --table customers --build
dotnet run --project src/GeradorCodigo.Api --launch-profile http # API em :5080 (POST /api/generation)

# 3) Sobe a API gerada (porta 5081)
dotnet run --project Generated/customers/Backend/Customer.Api
#   → Swagger: http://localhost:5081/swagger
#   → REST:    http://localhost:5181/api/customers  (use 5081)
#   → GraphQL: POST http://localhost:5081/graphql

# 4) Em outro terminal: sobe o Angular gerado (porta 4200, proxy → 5081)
cd Generated/customers/Frontend
npm install
npm start
#   → http://localhost:4200/customers
```

Alternativa via API: suba o gerador (`--launch-profile http`, porta 5080) e chame
`POST /api/generation` conforme a seção 6.
