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
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  min-height: 3.35rem;
  padding: 0.55rem 0.75rem;
  border-bottom: 1px solid var(--list-border);
}

.list-toolbar ::ng-deep .p-iconfield {
  width: 14rem;
}

.list-toolbar ::ng-deep .p-iconfield input {
  width: 100%;
  height: 1.9rem;
  padding: 0.4rem 0.75rem 0.4rem 2.15rem;
  color: #34445b;
  font-size: 0.75rem;
  border-color: #d5dce7;
  border-radius: 4px;
}

.list-toolbar ::ng-deep .p-iconfield input::placeholder {
  color: #7a8799;
}

.list-toolbar ::ng-deep .p-iconfield .p-inputicon {
  left: 0.75rem;
  color: #7b899c;
}

.list-toolbar ::ng-deep .p-iconfield .p-inputicon i {
  font-size: 0.75rem;
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

.column-tools ::ng-deep .p-column-filter {
  display: inline-flex;
  align-items: center;
}

.column-tools ::ng-deep .p-column-filter-menu-button {
  width: 1.2rem;
  height: 1.2rem;
  color: #748296;
  border-radius: 4px;
}

.column-tools ::ng-deep .p-column-filter-menu-button:hover {
  color: #059669;
  background: #e4f8f1;
}

.column-tools ::ng-deep .p-column-filter-menu-button.p-column-filter-menu-button-active,
.column-tools ::ng-deep .p-column-filter-menu-button.p-column-filter-menu-button-open {
  color: #059669;
  background: #e4f8f1;
}

.column-tools ::ng-deep .p-column-filter-menu {
  min-width: 12rem;
}

.column-tools ::ng-deep .p-column-filter-constraint {
  padding: 0.5rem 0.75rem;
}

.column-tools ::ng-deep .p-column-filter-constraint .p-dropdown,
.column-tools ::ng-deep .p-column-filter-constraint .p-inputtext,
.column-tools ::ng-deep .p-column-filter-constraint .p-multiselect {
  width: 100%;
  font-size: 0.75rem;
}

.column-tools ::ng-deep .p-column-filter-constraint .p-slider {
  width: 100%;
  margin: 0.5rem 0;
}

.column-tools ::ng-deep .p-column-filter-clear-button {
  margin-top: 0.5rem;
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

  .list-toolbar ::ng-deep .p-iconfield {
    width: 100%;
  }
}
