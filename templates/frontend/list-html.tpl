<p-toast></p-toast>
<p-confirmDialog></p-confirmDialog>

<section class="list-page">
  <div class="list-heading">
    <div>
      <h1>Filtragem</h1>
      <span class="list-total">{{ service.totalCount() }} registro(s)</span>
    </div>
    <p-button label="Novo" icon="pi pi-plus" size="small" (onClick)="create()" />
  </div>

  <div class="list-card">
    <div class="list-toolbar">
      <p-button
        label="Limpar"
        icon="pi pi-filter"
        severity="success"
        [outlined]="true"
        size="small"
        (onClick)="clearFilters()"
      />

      <label class="list-search">
        <i class="pi pi-search" aria-hidden="true"></i>
        <input
          pInputText
          type="search"
          placeholder="Buscar palavra-chave"
          aria-label="Buscar palavra-chave"
          [ngModel]="searchText()"
          (ngModelChange)="onSearchChange($event)"
        />
      </label>
    </div>

    <div class="list-table-scroll">
      <p-table
        [value]="service.items()"
        [lazy]="true"
        [lazyLoadOnInit]="false"
        [loading]="service.loading()"
        [sortField]="sortField()"
        [sortOrder]="sortOrder()"
        [resetPageOnSort]="true"
        (onLazyLoad)="onLazyLoad($event)"
        class="list-data-table"
      >
        <ng-template pTemplate="header">
          <tr>
[[#each ListFields]]            <th pSortableColumn="[[ParamName]]" class="list-header-cell">
              <div class="column-heading">
                <span>[[DisplayName]]</span>
                <span class="column-tools">
                  <i class="pi pi-filter list-filter-icon" aria-hidden="true"></i>
[[#if IsSortable]]                  <p-sortIcon field="[[ParamName]]" />[[/if]]                </span>
              </div>
            </th>
[[/each]]            <th class="actions-column list-header-cell">Ações</th>
          </tr>
        </ng-template>

        <ng-template pTemplate="body" let-item>
          <tr>
[[#each ListFields]][[#if IsBoolean]]            <td class="list-data-cell">
              @if (item.[[TsProperty]] !== null && item.[[TsProperty]] !== undefined) {
                <span [class]="'value-tag ' + tagClass(item.[[TsProperty]])">
                  {{ item.[[TsProperty]] ? 'Sim' : 'Não' }}
                </span>
              } @else {
                <span class="empty-value">—</span>
              }
            </td>
[[/if]][[#if IsEnum]]            <td class="list-data-cell">
              @if (item.[[TsProperty]] !== null && item.[[TsProperty]] !== undefined) {
                <span [class]="'value-tag ' + tagClass(item.[[TsProperty]])">
                  {{ item.[[TsProperty]] }}
                </span>
              } @else {
                <span class="empty-value">—</span>
              }
            </td>
[[/if]][[#if IsDecimal]]            <td class="list-data-cell">
              @if (item.[[TsProperty]] !== null && item.[[TsProperty]] !== undefined) {
                {{ item.[[TsProperty]] | number: '1.2-2' }}
              } @else {
                <span class="empty-value">—</span>
              }
            </td>
[[/if]][[#if IsDate]]            <td class="list-data-cell">
              @if (item.[[TsProperty]] !== null && item.[[TsProperty]] !== undefined) {
                {{ item.[[TsProperty]] | date: 'dd/MM/yyyy' }}
              } @else {
                <span class="empty-value">—</span>
              }
            </td>
[[/if]][[#if IsFullDateTime]]            <td class="list-data-cell">
              @if (item.[[TsProperty]] !== null && item.[[TsProperty]] !== undefined) {
                {{ item.[[TsProperty]] | date: 'dd/MM/yyyy HH:mm' }}
              } @else {
                <span class="empty-value">—</span>
              }
            </td>
[[/if]][[#if IsPlainListField]]            <td class="list-data-cell">
              @if (item.[[TsProperty]] !== null && item.[[TsProperty]] !== undefined) {
                {{ item.[[TsProperty]] }}
              } @else {
                <span class="empty-value">—</span>
              }
            </td>
[[/if]][[/each]]            <td class="actions-column">
              <div class="row-actions">
                <p-button
                  icon="pi pi-pencil"
                  [rounded]="true"
                  [text]="true"
                  size="small"
                  (onClick)="edit(item)"
                  ariaLabel="Editar"
                />
                <p-button
                  icon="pi pi-trash"
                  [rounded]="true"
                  [text]="true"
                  size="small"
                  severity="danger"
                  (onClick)="remove(item)"
                  ariaLabel="Excluir"
                />
              </div>
            </td>
          </tr>
        </ng-template>

        <ng-template pTemplate="emptymessage">
          <tr>
            <td [attr.colspan]="[[ListFieldCount]] + 1">
              <div class="empty-state">
                <i class="pi pi-search" aria-hidden="true"></i>
                <strong>Nenhum registro encontrado</strong>
                <span>Ajuste a busca ou adicione um novo registro.</span>
              </div>
            </td>
          </tr>
        </ng-template>
      </p-table>
    </div>

    <div class="list-pagination" [class.list-pagination--empty]="service.totalCount() === 0">
      <p-paginator
        [first]="firstRecordIndex()"
        [rows]="pageSize()"
        [totalRecords]="service.totalCount()"
        [rowsPerPageOptions]="pageSizeOptions"
        [alwaysShow]="true"
        [showCurrentPageReport]="false"
        [showFirstLastIcon]="true"
        [showJumpToPageDropdown]="false"
        [showPageLinks]="true"
        (onPageChange)="onPageChange($event)"
        class="list-paginator"
      ></p-paginator>
    </div>
  </div>
</section>
