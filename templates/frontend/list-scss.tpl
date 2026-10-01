:host {
  --list-border: #e2e7ef;
  --list-header: #f8fafc;
  --list-text: #29384e;
  --list-muted: #6b7b91;

  display: block;
  color: var(--list-text);
}

.list-page {
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.list-heading,
.list-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.list-heading h1 {
  margin: 0;
  color: #1f2d42;
  font-size: 1rem;
  font-weight: 600;
}

.list-total {
  display: block;
  margin-top: 0.15rem;
  color: var(--list-muted);
  font-size: 0.75rem;
}

.list-card {
  overflow: hidden;
  background: #fff;
  border: 1px solid var(--list-border);
  border-radius: 4px;
  box-shadow: 0 1px 2px rgb(15 23 42 / 0.04);
}

.list-toolbar {
  min-height: 3.35rem;
  padding: 0.55rem 0.75rem;
  border-bottom: 1px solid var(--list-border);
}

.list-search {
  position: relative;
  display: block;
  width: 11rem;
}

.list-search > i {
  position: absolute;
  top: 50%;
  left: 0.75rem;
  z-index: 1;
  color: #7b899c;
  font-size: 0.75rem;
  transform: translateY(-50%);
  pointer-events: none;
}

.list-search input {
  width: 100%;
  height: 1.9rem;
  padding: 0.4rem 0.75rem 0.4rem 2.15rem;
  color: #34445b;
  font-size: 0.75rem;
  border-color: #d5dce7;
  border-radius: 4px;
}

.list-search input::placeholder {
  color: #7a8799;
}

.list-search input::-webkit-search-cancel-button {
  display: none;
}

.list-table-scroll {
  overflow-x: auto;
}

:host ::ng-deep .list-data-table {
  border: 0;
}

:host ::ng-deep .list-data-table .p-datatable-table {
  min-width: 62rem;
  border-collapse: collapse;
}

:host ::ng-deep .list-data-table :is(.p-datatable-thead > tr > th, .p-datatable-tbody > tr > td) {
  padding: 0 1rem;
  border-color: var(--list-border);
  text-align: left;
  vertical-align: middle;
}

:host ::ng-deep .list-data-table .p-datatable-thead > tr > th {
  height: 3.15rem;
  color: #3b4a61;
  background: var(--list-header);
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

:host ::ng-deep .list-data-table .p-datatable-tbody > tr > td {
  height: 3.15rem;
  color: var(--list-text);
  font-size: 0.75rem;
  white-space: nowrap;
}

:host ::ng-deep .list-data-table .p-datatable-tbody > tr:last-child > td {
  border-bottom: 0;
}

.column-heading,
.column-tools {
  display: flex;
  align-items: center;
}

.column-heading {
  justify-content: space-between;
  gap: 0.9rem;
}

.column-tools {
  gap: 0.45rem;
}

.list-filter-icon {
  color: #56657a;
  font-size: 0.8rem;
}

.column-tools ::ng-deep .p-sortable-column-icon {
  width: 0.7rem;
  height: 0.7rem;
  margin: 0;
  color: #748296;
}

.value-tag {
  display: inline-flex;
  align-items: center;
  min-height: 1.4rem;
  padding: 0.22rem 0.5rem;
  border-radius: 4px;
  font-size: 0.68rem;
  line-height: 1;
  text-transform: lowercase;
  white-space: nowrap;
}

.value-tag--success {
  color: #07845c;
  background: #dcfce7;
}

.value-tag--danger {
  color: #dc3545;
  background: #ffe4e6;
}

.value-tag--warning {
  color: #d97706;
  background: #fff0d5;
}

.value-tag--info {
  color: #1971c2;
  background: #e3f2fd;
}

.value-tag--neutral {
  color: #526176;
  background: #edf1f5;
}

.empty-value {
  color: #9aa6b5;
}

.actions-column {
  width: 6rem;
  text-align: center !important;
}

.row-actions {
  display: flex;
  justify-content: center;
  gap: 0.2rem;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
  min-height: 14rem;
  color: var(--list-muted);
  font-size: 0.75rem;
}

.empty-state i {
  color: #94a3b8;
  font-size: 1.5rem;
}

.empty-state strong {
  color: #46566c;
  font-size: 0.85rem;
}

.list-pagination {
  display: flex;
  justify-content: center;
  min-height: 3.35rem;
  padding: 0.4rem 0.75rem;
  background: var(--list-header);
  border-top: 1px solid var(--list-border);
}

.list-pagination--empty {
  display: none;
}

:host ::ng-deep .list-paginator.p-paginator {
  justify-content: center;
  background: transparent;
  border: 0;
}

:host ::ng-deep .list-paginator .p-paginator-rpp-dropdown {
  display: none;
}

:host ::ng-deep .list-paginator .p-paginator-page {
  min-width: 2rem;
  height: 2rem;
  margin: 0 0.08rem;
  color: #536277;
  border-radius: 999px;
  font-size: 0.75rem;
}

:host ::ng-deep .list-paginator .p-paginator-page.p-paginator-page-selected {
  color: #059669;
  background: #e4f8f1;
  font-weight: 600;
}

@media (max-width: 40rem) {
  .list-toolbar {
    flex-wrap: wrap;
  }

  .list-search {
    width: 100%;
  }
}
