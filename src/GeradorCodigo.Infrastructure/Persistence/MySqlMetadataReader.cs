using GeradorCodigo.Application.Exceptions;
using GeradorCodigo.Domain.Abstractions;
using GeradorCodigo.Domain.Metadata;
using Microsoft.Extensions.Configuration;
using MySqlConnector;

namespace GeradorCodigo.Infrastructure.Persistence;

/// <summary>
/// Lê a estrutura das tabelas diretamente do INFORMATION_SCHEMA do MySQL.
/// Todas as consultas usam parâmetros — nenhum valor fornecido pelo usuário é concatenado em SQL.
/// </summary>
public sealed class MySqlMetadataReader(IConfiguration configuration) : IMetadataReader
{
    public async Task<TableMetadata> ReadTableAsync(string tableName, CancellationToken cancellationToken = default)
    {
        await using var connection = await OpenConnectionAsync(cancellationToken);
        var schema = connection.Database;

        // Localiza o nome real da tabela de forma case-insensitive
        // (compatível com lower_case_table_names = 0 ou 1).
        var actualName = await FindTableNameAsync(connection, schema, tableName, cancellationToken)
            ?? throw new TableNotFoundException(tableName);

        var exists = await TableExistsAsync(connection, schema, actualName, cancellationToken);
        if (!exists)
        {
            throw new TableNotFoundException(tableName);
        }

        var columns = await ReadColumnsAsync(connection, schema, actualName, cancellationToken);
        if (columns.Count == 0)
        {
            throw new TableNotFoundException(tableName);
        }

        var primaryKey = await ReadPrimaryKeyAsync(connection, schema, actualName, cancellationToken);
        var foreignKeys = await ReadForeignKeysAsync(connection, schema, actualName, cancellationToken);
        var indexes = await ReadIndexesAsync(connection, schema, actualName, cancellationToken);
        var comment = await ReadTableCommentAsync(connection, schema, actualName, cancellationToken);

        var marked = columns.Select(column => column with
        {
            IsPrimaryKey = primaryKey.Contains(column.Name, StringComparer.OrdinalIgnoreCase),
            ForeignKeys = foreignKeys.Where(fk =>
                string.Equals(fk.ColumnName, column.Name, StringComparison.OrdinalIgnoreCase)).ToList(),
            IndexNames = indexes.Where(ix => ix.Columns.Contains(column.Name, StringComparer.OrdinalIgnoreCase))
                .Select(ix => ix.Name)
                .ToList(),
        }).ToList();

        return new TableMetadata
        {
            Name = actualName,
            Schema = schema,
            Comment = comment,
            Columns = marked,
            PrimaryKeyColumns = primaryKey,
            Indexes = indexes,
        };
    }

    private static async Task<string?> FindTableNameAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT TABLE_NAME
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = @schema AND LOWER(TABLE_NAME) = LOWER(@table)
            LIMIT 1
            """;
        await using var command = CreateCommand(connection, sql, schema, table);
        return (await command.ExecuteScalarAsync(ct)) as string;
    }

    private async Task<MySqlConnection> OpenConnectionAsync(CancellationToken cancellationToken)
    {
        var connectionString = configuration.GetConnectionString("MySql");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new GenerationException(
                "Connection string 'MySql' não configurada. " +
                "Defina ConnectionStrings__MySql via variável de ambiente ou appsettings.");
        }

        var connection = new MySqlConnection(connectionString);
        try
        {
            await connection.OpenAsync(cancellationToken);
            return connection;
        }
        catch (Exception ex)
        {
            await connection.DisposeAsync();
            throw new GenerationException($"Falha ao conectar no MySQL: {ex.Message}");
        }
    }

    private static async Task<bool> TableExistsAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table
            """;
        await using var command = CreateCommand(connection, sql, schema, table);
        var count = Convert.ToInt32(await command.ExecuteScalarAsync(ct));
        return count > 0;
    }

    private static async Task<string> ReadTableCommentAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT TABLE_COMMENT
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table
            """;
        await using var command = CreateCommand(connection, sql, schema, table);
        return (await command.ExecuteScalarAsync(ct)) as string ?? string.Empty;
    }

    private static async Task<List<ColumnMetadata>> ReadColumnsAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT COLUMN_NAME, ORDINAL_POSITION, COLUMN_TYPE, DATA_TYPE,
                   CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE,
                   DATETIME_PRECISION, IS_NULLABLE, COLUMN_DEFAULT, EXTRA, COLUMN_COMMENT
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table
            ORDER BY ORDINAL_POSITION
            """;

        var columns = new List<ColumnMetadata>();
        await using var command = CreateCommand(connection, sql, schema, table);
        await using var reader = await command.ExecuteReaderAsync(ct);

        while (await reader.ReadAsync(ct))
        {
            var dataType = reader.GetString(3); // DATA_TYPE
            var extra = reader.IsDBNull(10) ? string.Empty : reader.GetString(10); // EXTRA

            columns.Add(new ColumnMetadata
            {
                Name = reader.GetString(0),
                OrdinalPosition = reader.GetInt32(1),
                ColumnType = reader.GetString(2),
                DataType = dataType,
                CharacterMaximumLength = await ReadNullableIntAsync(reader, 4, ct),
                NumericPrecision = await ReadNullableIntAsync(reader, 5, ct),
                NumericScale = await ReadNullableIntAsync(reader, 6, ct),
                DateTimePrecision = await ReadNullableIntAsync(reader, 7, ct),
                IsNullable = string.Equals(reader.GetString(8), "YES", StringComparison.OrdinalIgnoreCase),
                Default = reader.IsDBNull(9) ? null : reader.GetValue(9)?.ToString(),
                IsAutoIncrement = extra.Contains("auto_increment", StringComparison.OrdinalIgnoreCase),
                IsPrimaryKey = false, // preenchido depois
                Comment = reader.IsDBNull(11) ? null : reader.GetString(11),
                EnumName = dataType == "enum" ? reader.GetString(2) : null,
                EnumValues = dataType == "enum" ? ParseEnumValues(reader.GetString(2)) : [],
            });
        }

        return columns;
    }

    private static async Task<List<string>> ReadPrimaryKeyAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table AND CONSTRAINT_NAME = 'PRIMARY'
            ORDER BY ORDINAL_POSITION
            """;
        return await ReadStringsAsync(connection, sql, schema, table, ct);
    }

    private static async Task<List<ForeignKeyMetadata>> ReadForeignKeysAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table
              AND REFERENCED_TABLE_NAME IS NOT NULL
            ORDER BY CONSTRAINT_NAME, ORDINAL_POSITION
            """;

        var keys = new List<ForeignKeyMetadata>();
        await using var command = CreateCommand(connection, sql, schema, table);
        await using var reader = await command.ExecuteReaderAsync(ct);

        while (await reader.ReadAsync(ct))
        {
            keys.Add(new ForeignKeyMetadata
            {
                ConstraintName = reader.GetString(0),
                ColumnName = reader.GetString(1),
                ReferencedTable = reader.GetString(2),
                ReferencedColumn = reader.GetString(3),
            });
        }

        return keys;
    }

    private static async Task<List<IndexMetadata>> ReadIndexesAsync(
        MySqlConnection connection, string schema, string table, CancellationToken ct)
    {
        const string sql = """
            SELECT INDEX_NAME, NON_UNIQUE, COLUMN_NAME, SEQ_IN_INDEX
            FROM INFORMATION_SCHEMA.STATISTICS
            WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table
            ORDER BY INDEX_NAME, SEQ_IN_INDEX
            """;

        var map = new Dictionary<string, IndexMetadata>(StringComparer.OrdinalIgnoreCase);
        var ordered = new List<IndexMetadata>();

        await using var command = CreateCommand(connection, sql, schema, table);
        await using var reader = await command.ExecuteReaderAsync(ct);

        while (await reader.ReadAsync(ct))
        {
            var name = reader.GetString(0);
            if (string.Equals(name, "PRIMARY", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            if (!map.TryGetValue(name, out var index))
            {
                index = new IndexMetadata
                {
                    Name = name,
                    IsUnique = reader.GetInt32(1) == 0,
                    Columns = [],
                };
                map[name] = index;
                ordered.Add(index);
            }

            var position = reader.GetInt32(3);
            var columns = index.Columns.ToList();
            while (columns.Count < position)
            {
                columns.Add(string.Empty);
            }

            columns[position - 1] = reader.GetString(2);
            map[name] = index with { Columns = columns };
        }

        return map.Values.Where(ix => ix.Columns.All(c => c.Length > 0)).ToList();
    }

    private static async Task<List<string>> ReadStringsAsync(
        MySqlConnection connection, string sql, string schema, string table, CancellationToken ct)
    {
        var values = new List<string>();
        await using var command = CreateCommand(connection, sql, schema, table);
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            values.Add(reader.GetString(0));
        }

        return values;
    }

    private static MySqlCommand CreateCommand(MySqlConnection connection, string sql, string schema, string table)
    {
        var command = connection.CreateCommand();
        command.CommandText = sql;
        command.Parameters.AddWithValue("@schema", schema);
        command.Parameters.AddWithValue("@table", table);
        return command;
    }

    private static async Task<int?> ReadNullableIntAsync(MySqlDataReader reader, int ordinal, CancellationToken ct)
    {
        return await reader.IsDBNullAsync(ordinal, ct) ? null : Convert.ToInt32(reader.GetValue(ordinal));
    }

    /// <summary>Extrai os valores de uma coluna ENUM a partir do COLUMN_TYPE.</summary>
    internal static IReadOnlyList<string> ParseEnumValues(string columnType)
    {
        var values = new List<string>();
        var inside = false;
        var current = new System.Text.StringBuilder();

        foreach (var character in columnType)
        {
            if (character == '\'')
            {
                if (inside)
                {
                    values.Add(current.ToString());
                    current.Clear();
                    inside = false;
                }
                else
                {
                    inside = true;
                }
                continue;
            }

            if (inside)
            {
                current.Append(character);
            }
        }

        return values;
    }
}
