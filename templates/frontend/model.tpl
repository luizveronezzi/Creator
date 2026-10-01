/** Modelo de [[EntityPlural]] espelhando os DTOs da API. */
export type [[EntityPlural]] = {
[[#each Fields]]  [[TsProperty]][[#if IsNullable]]?[[/if]]: [[TypeScriptType]][[#if IsNullable]] | null[[/if]];
[[/each]]};

/** Payload de criação (sem campos auto incremento). */
export type [[EntityPlural]]CreateRequest = {
[[#each EditableFields]]  [[TsProperty]][[#if IsNullable]]?[[/if]]: [[TypeScriptType]][[#if IsNullable]] | null[[/if]];
[[/each]]};

/** Payload de alteração (o identificador vai na rota). */
export type [[EntityPlural]]UpdateRequest = {
[[#each EditableFields]]  [[TsProperty]][[#if IsNullable]]?[[/if]]: [[TypeScriptType]][[#if IsNullable]] | null[[/if]];
[[/each]]};

/** Resultado paginado retornado pela API. */
export type PagedResult<T> = {
  items: T[];
  page: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
};

/** Envelope de erro padronizado pela API. */
export type ApiError = {
  success: boolean;
  message: string;
  errors: string[];
};

/** Opção de campo select. */
export type SelectOption = {
  label: string;
  value: unknown;
};
