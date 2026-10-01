# GERADOR-CODIGO — ESPECIFICAÇÃO DO PROJETO

Crie uma aplicação completa chamada **Gerador-Codigo**, responsável por gerar automaticamente código Backend e Frontend a partir da estrutura de uma tabela existente em um banco de dados MySQL.

O sistema deve ser desenvolvido seguindo boas práticas de **Clean Code, Clean Architecture, SOLID, baixo acoplamento, alta coesão, separação de responsabilidades e código fortemente tipado**.

Não crie apenas exemplos ou pseudocódigo. Gere uma estrutura de projeto funcional, compilável e organizada.

---

# 1. OBJETIVO DA APLICAÇÃO

A aplicação deverá receber como entrada o nome de uma tabela existente no banco de dados MySQL.

Exemplo:

    CUSTOMERS

A aplicação deverá consultar o banco de dados e obter automaticamente a estrutura completa dessa tabela.

A partir dessa estrutura, deverá gerar automaticamente:

1. Backend em .NET;
2. API REST utilizando Minimal API;
3. Endpoint GraphQL;
4. Entidades;
5. DTOs;
6. Repositórios;
7. Serviços;
8. Validações;
9. CRUD completo;
10. Frontend Angular;
11. Tela de listagem;
12. Formulário de inclusão/alteração;
13. Serviços Angular para comunicação com a API;
14. Models/Interfaces TypeScript;
15. Rotas;
16. Componentes utilizando PrimeNG/Sakai.

O sistema deve ser um **gerador de código**, portanto os arquivos deverão ser criados fisicamente em diretórios de saída definidos pela aplicação.

---

# 2. TECNOLOGIAS OBRIGATÓRIAS

## Backend

Utilizar:

- .NET na versão LTS mais recente disponível no momento da geração;
- C#;
- ASP.NET Core;
- Minimal API;
- MySQL;
- Entity Framework Core;
- GraphQL;
- Dependency Injection;
- FluentValidation, quando aplicável;
- OpenAPI/Swagger.

Não utilizar Controllers MVC tradicionais.

---

# 3. ARQUITETURA DO BACKEND

Utilizar Clean Architecture.

A solução deverá possuir, no mínimo, os seguintes projetos:

    src/
    ├── GeradorCodigo.Api
    ├── GeradorCodigo.Application
    ├── GeradorCodigo.Domain
    └── GeradorCodigo.Infrastructure

Responsabilidades:

## Domain

Deverá conter:

- Entities;
- Value Objects;
- Enums;
- Interfaces de domínio;
- Regras de negócio independentes de infraestrutura.

## Application

Deverá conter:

- DTOs;
- Interfaces;
- Services;
- Use Cases;
- Validators;
- Regras de aplicação.

A Application não deverá depender diretamente de MySQL.

## Infrastructure

Deverá conter:

- Entity Framework Core;
- DbContext;
- Configurações das entidades;
- Repositories;
- acesso ao MySQL;
- implementação das interfaces;
- mecanismos de geração dos arquivos.

## Api

Deverá conter:

- Minimal APIs;
- configuração da aplicação;
- Dependency Injection;
- Middleware;
- tratamento global de exceções;
- Swagger/OpenAPI;
- GraphQL.

---

# 4. LEITURA DA ESTRUTURA DO MYSQL

Ao receber o nome de uma tabela, consultar o `INFORMATION_SCHEMA` do MySQL.

Obter, no mínimo:

- nome da tabela;
- nome da coluna;
- ordem da coluna;
- tipo;
- tamanho;
- precisão;
- escala;
- nullable;
- default;
- auto_increment;
- chave primária;
- índices;
- foreign keys;
- tabela relacionada;
- coluna relacionada;
- comentário da coluna.

Não assumir previamente a estrutura da tabela.

Toda a geração deverá ser baseada nos metadados efetivamente retornados pelo banco.

---

# 5. MAPEAMENTO MYSQL → C#

Criar uma camada responsável pelo mapeamento dos tipos.

Exemplo:

    INT       → int
    BIGINT    → long
    SMALLINT  → short
    TINYINT   → byte
    DECIMAL   → decimal
    FLOAT     → float
    DOUBLE    → double
    VARCHAR   → string
    CHAR      → string
    TEXT      → string
    DATE      → DateOnly
    DATETIME  → DateTime
    TIMESTAMP → DateTime
    TIME      → TimeOnly
    BIT       → bool
    BLOB      → byte[]

Quando a coluna aceitar `NULL`, utilizar tipos nullable:

    int?
    decimal?
    DateTime?
    bool?

Strings deverão respeitar nullable reference types.

---

# 6. GERAÇÃO DO BACKEND

Para cada tabela informada, criar uma pasta com o nome da tabela.

Exemplo:

    Generated/
    └── CUSTOMERS/
        └── Backend/

Gerar:

- Entity
- DTO
- Repository
- RepositoryInterface
- Service
- ServiceInterface
- Validator
- DbContextConfiguration
- Endpoints
- GraphQL

---

# 7. ENDPOINTS REST

Para cada tabela gerar os seguintes endpoints:

    GET    /api/{table}
    GET    /api/{table}/{id}
    POST   /api/{table}
    PUT    /api/{table}/{id}
    DELETE /api/{table}/{id}

O endpoint GET de listagem deverá permitir, quando aplicável:

- paginação;
- ordenação;
- filtros;
- busca.

Os endpoints deverão utilizar DTOs e não expor diretamente entidades do domínio.

---

# 8. GRAPHQL

A aplicação deverá disponibilizar um endpoint GraphQL.

O GraphQL deverá utilizar as mesmas camadas de Application e Infrastructure utilizadas pela API REST.

Não permitir que o GraphQL acesse diretamente o banco ignorando as regras da aplicação.

Gerar queries para consulta dos registros da tabela.

Exemplo conceitual:

    query {
        customers {
            id
            name
            email
        }
    }

---

# 9. GERAÇÃO DO FRONTEND

Utilizar:

- Angular na versão LTS mais recente;
- Standalone Components;
- TypeScript;
- Reactive Forms;
- Angular Router;
- HttpClient;
- Signals quando apropriado;
- PrimeNG;
- Template Sakai.

A estrutura deverá ser organizada por funcionalidade.

Exemplo:

    Generated/
    └── CUSTOMERS/
        └── Frontend/
            └── customers/
                ├── components/
                ├── services/
                ├── models/
                └── pages/

---

# 10. TELA DE LISTAGEM

Para cada tabela gerar uma tela contendo:

- tabela PrimeNG;
- paginação;
- ordenação;
- filtro;
- botão Novo;
- botão Editar;
- botão Excluir;
- confirmação de exclusão;
- indicador de carregamento;
- tratamento de erros;
- mensagem quando não houver registros.

Utilizar componentes do template Sakai/PrimeNG.

---

# 11. FORMULÁRIO

Criar automaticamente o formulário com base nos tipos das colunas.

Mapeamento:

    VARCHAR / CHAR
        → InputText

    TEXT
        → Textarea

    INT / BIGINT / DECIMAL
        → InputNumber

    DATE
        → DatePicker

    DATETIME
        → DateTimePicker

    BOOLEAN / BIT
        → Checkbox

    ENUM
        → Select

    FOREIGN KEY
        → Select relacionado

Campos `AUTO_INCREMENT` deverão ser identificados automaticamente.

Campos somente leitura deverão ser desabilitados no formulário.

---

# 12. VALIDAÇÃO

As validações deverão ser geradas automaticamente a partir dos metadados do banco.

Exemplos:

    NOT NULL
        → campo obrigatório

    VARCHAR(100)
        → maxlength = 100

    DECIMAL(10,2)
        → respeitar precisão e escala

    PRIMARY KEY
        → campo identificador

    AUTO_INCREMENT
        → somente leitura no cadastro

As mesmas regras importantes deverão existir no Backend e Frontend.

---

# 13. TRATAMENTO DE ERROS

Criar tratamento global de exceções no Backend.

A API deverá retornar respostas padronizadas.

Exemplo:

    {
        "success": false,
        "message": "Erro ao processar a solicitação.",
        "errors": []
    }

No Angular, erros da API deverão ser apresentados ao usuário através dos componentes apropriados do PrimeNG.

---

# 14. CONFIGURAÇÃO DO BANCO

A Connection String do MySQL não deverá ficar hardcoded.

Utilizar:

    appsettings.json

e permitir configuração através de variáveis de ambiente.

Exemplo:

    {
      "ConnectionStrings": {
        "MySql": ""
      }
    }

---

# 15. GERAÇÃO DOS ARQUIVOS

A aplicação deverá possuir um serviço responsável pela geração dos arquivos.

Exemplo:

    ICodeGenerator
    CodeGenerator
    TemplateEngine
    MetadataReader
    TypeMapper

A geração deverá ser baseada em templates.

Não colocar grandes blocos de código diretamente dentro das classes responsáveis pela geração.

Utilizar templates separados para:

- Entity;
- DTO;
- Repository;
- Service;
- Endpoint;
- GraphQL;
- Angular Model;
- Angular Service;
- Component;
- HTML;
- SCSS.

---

# 16. ESTRUTURA FINAL GERADA

Para uma tabela chamada `CUSTOMERS`, gerar algo semelhante a:

    Generated/
    └── CUSTOMERS/
        │
        ├── Backend/
        │   ├── Domain/
        │   │   └── Entities/
        │   │       └── Customer.cs
        │   │
        │   ├── Application/
        │   │   ├── DTOs/
        │   │   ├── Interfaces/
        │   │   ├── Services/
        │   │   └── Validators/
        │   │
        │   ├── Infrastructure/
        │   │   ├── Persistence/
        │   │   └── Repositories/
        │   │
        │   └── Api/
        │       ├── Endpoints/
        │       └── GraphQL/
        │
        └── Frontend/
            └── customers/
                ├── components/
                ├── pages/
                ├── services/
                └── models/

---

# 17. SEGURANÇA E BOAS PRÁTICAS

Não armazenar senha do banco no código-fonte.

Utilizar:

- configuração externa;
- variáveis de ambiente;
- validação de entrada;
- parâmetros SQL;
- Entity Framework Core;
- tratamento de exceções;
- logs;
- CancellationToken;
- async/await.

Não utilizar:

- SQL concatenado com dados fornecidos pelo usuário;
- credenciais hardcoded;
- acesso direto ao banco dentro dos endpoints;
- lógica de negócio dentro da camada API.

---

# 18. LOGGING

Utilizar `ILogger<T>` e registrar:

- início da geração;
- tabela processada;
- quantidade de campos encontrados;
- arquivos gerados;
- erros;
- tempo de execução.

Não registrar senhas ou informações sensíveis.

---

# 19. REGRAS DE SOBRESCRITA

Antes de gerar uma tabela que já possua arquivos:

1. verificar se a pasta existe;
2. identificar os arquivos existentes;
3. informar ao usuário;
4. solicitar confirmação antes de sobrescrever arquivos existentes.

Nunca apagar silenciosamente código existente.

---

# 20. EXECUÇÃO DA GERAÇÃO

A aplicação deverá permitir informar:

    Nome da tabela

e executar:

    Ler metadados
          ↓
    Validar tabela
          ↓
    Mapear tipos
          ↓
    Identificar PK
          ↓
    Identificar Foreign Keys
          ↓
    Gerar Backend
          ↓
    Gerar API
          ↓
    Gerar GraphQL
          ↓
    Gerar Frontend
          ↓
    Validar arquivos
          ↓
    Exibir resultado

---

# 21. QUALIDADE DO CÓDIGO

Todo código gerado deverá:

- compilar;
- seguir convenções de nomenclatura;
- utilizar nullable reference types;
- utilizar async/await;
- utilizar CancellationToken quando apropriado;
- evitar código duplicado;
- seguir SOLID;
- manter separação de responsabilidades;
- possuir comentários apenas quando agregarem valor;
- evitar métodos excessivamente grandes;
- evitar classes com múltiplas responsabilidades.

---

# 22. DOCUMENTAÇÃO

Gerar também:

    README.md

contendo:

- requisitos;
- instalação;
- configuração do MySQL;
- configuração da connection string;
- execução do projeto;
- geração de código;
- estrutura das pastas;
- exemplos de utilização da API REST;
- exemplos de utilização do GraphQL;
- execução do Angular.

---

# 23. CRITÉRIOS DE ACEITAÇÃO

A implementação será considerada concluída somente quando:

1. A aplicação iniciar sem erros;
2. Conseguir conectar ao MySQL;
3. Conseguir receber o nome de uma tabela;
4. Conseguir ler seus metadados;
5. Conseguir identificar sua chave primária;
6. Conseguir identificar tipos e nullable;
7. Conseguir identificar auto_increment;
8. Conseguir gerar o Backend;
9. Conseguir gerar CRUD REST;
10. Conseguir gerar GraphQL;
11. Conseguir gerar Frontend Angular;
12. Conseguir gerar Table;
13. Conseguir gerar Form;
14. Conseguir gerar validações;
15. Conseguir compilar o código gerado;
16. Não sobrescrever arquivos existentes sem confirmação.

---

# 24. FORMA DE ENTREGA

Não entregue somente trechos de código.

Entregue a estrutura completa do projeto, incluindo:

- `.sln`;
- `.csproj`;
- arquivos `.cs`;
- arquivos Angular;
- configurações;
- templates;
- README;
- scripts necessários.

Sempre que possível, valide a compilação do Backend e a estrutura do Frontend antes de considerar a geração concluída.

Caso alguma decisão técnica não esteja especificada neste documento, escolha a alternativa mais simples, moderna e alinhada às versões LTS utilizadas, documentando a decisão no README.

---

# 25. REGRA IMPORTANTE PARA A IA

Antes de iniciar a implementação:

1. Analise todos os requisitos deste documento.
2. Identifique requisitos ambíguos ou conflitantes.
3. Não invente funcionalidades que não sejam necessárias.
4. Quando uma decisão técnica for necessária e não estiver especificada, escolha uma solução compatível com a arquitetura definida.
5. Mantenha a separação entre o código do próprio Gerador-Codigo e o código que será gerado.
6. Não implemente um CRUD específico para uma tabela fixa: o sistema deve ser genérico e baseado nos metadados do MySQL.
7. O nome da tabela e suas colunas devem ser tratados dinamicamente.
8. A geração deve funcionar para múltiplas tabelas sem necessidade de alterar o código-fonte do Gerador-Codigo.
9. Priorize código realmente executável em vez de exemplos simplificados.
10. Ao finalizar, apresente a estrutura criada e os passos necessários para executar e testar o projeto.
