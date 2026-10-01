import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ConfirmationService, MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { InputTextModule } from 'primeng/inputtext';
import { PaginatorModule, PaginatorState } from 'primeng/paginator';
import { TableLazyLoadEvent, TableModule } from 'primeng/table';
import { ToastModule } from 'primeng/toast';
import { Subject, debounceTime, distinctUntilChanged } from 'rxjs';
import { [[EntityPlural]] } from '../../models/[[FeatureName]].model';
import { [[EntityPlural]]Service } from '../../services/[[FeatureName]].service';

/** Tela de listagem de [[EntityPlural]] com paginação, ordenação, busca e ações de CRUD. */
@Component({
  selector: 'app-[[FeatureName]]-list',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    PaginatorModule,
    ButtonModule,
    InputTextModule,
    ToastModule,
    ConfirmDialogModule,
  ],
  templateUrl: './[[FeatureName]]-list.component.html',
  styleUrl: './[[FeatureName]]-list.component.scss',
})
export class [[EntityPlural]]ListComponent implements OnInit {
  readonly service = inject([[EntityPlural]]Service);

  private readonly router = inject(Router);
  private readonly messageService = inject(MessageService);
  private readonly confirmationService = inject(ConfirmationService);
  private readonly searchChanges = new Subject<string>();

  readonly searchText = signal('');
  readonly pageSize = signal(10);
  readonly pageSizeOptions = [10, 20, 50];
  readonly firstRecordIndex = signal(0);
  readonly sortField = signal<string | undefined>(undefined);
  readonly sortOrder = signal(0);

  private readonly successTags = new Set([
    'active',
    'approved',
    'completed',
    'paid',
    'qualified',
    'success',
    'verified',
    'ativo',
    'aprovado',
    'concluido',
    'pago',
    'qualificado',
    'sucesso',
    'verificado',
  ]);
  private readonly dangerTags = new Set([
    'blocked',
    'cancelled',
    'inactive',
    'rejected',
    'unqualified',
    'bloqueado',
    'cancelado',
    'inativo',
    'rejeitado',
  ]);
  private readonly warningTags = new Set([
    'negotiation',
    'pending',
    'review',
    'renegociacao',
    'pendente',
    'revisao',
  ]);
  private readonly infoTags = new Set(['new', 'created', 'renewal', 'novo', 'renovacao']);

  constructor() {
    this.searchChanges
      .pipe(debounceTime(350), distinctUntilChanged(), takeUntilDestroyed())
      .subscribe(() => this.search());
  }

  ngOnInit(): void {
    this.loadPage(1);
  }

  onSearchChange(value: string): void {
    this.searchText.set(value);
    this.searchChanges.next(value);
  }

  search(): void {
    this.firstRecordIndex.set(0);
    this.loadPage(1);
  }

  clearFilters(): void {
    this.searchText.set('');
    this.sortField.set(undefined);
    this.sortOrder.set(0);
    this.firstRecordIndex.set(0);
    this.loadPage(1);
  }

  onLazyLoad(event: TableLazyLoadEvent): void {
    const rows = event.rows ?? this.pageSize();
    const first = event.first ?? 0;
    const hasSortOrder = event.sortOrder === 1 || event.sortOrder === -1;
    const sortField = hasSortOrder && typeof event.sortField === 'string' ? event.sortField : undefined;

    this.pageSize.set(rows);
    this.firstRecordIndex.set(first);
    this.sortField.set(sortField);
    this.sortOrder.set(hasSortOrder ? event.sortOrder! : 0);

    this.loadPage(Math.floor(first / rows) + 1);
  }

  onPageChange(event: PaginatorState): void {
    const rows = event.rows ?? this.pageSize();
    const first = event.first ?? 0;

    this.pageSize.set(rows);
    this.firstRecordIndex.set(first);
    this.loadPage(Math.floor(first / rows) + 1);
  }

  tagClass(value: unknown): string {
    if (typeof value === 'boolean') {
      return value ? 'value-tag--success' : 'value-tag--danger';
    }

    const normalized = String(value)
      .trim()
      .toLowerCase()
      .replace(/[_-]+/g, ' ');

    if (this.successTags.has(normalized)) {
      return 'value-tag--success';
    }

    if (this.dangerTags.has(normalized)) {
      return 'value-tag--danger';
    }

    if (this.warningTags.has(normalized)) {
      return 'value-tag--warning';
    }

    if (this.infoTags.has(normalized)) {
      return 'value-tag--info';
    }

    return 'value-tag--neutral';
  }

  create(): void {
    void this.router.navigate(['/[[FeatureName]]', 'new']);
  }

  edit(row: [[EntityPlural]]): void {
    void this.router.navigate(['/[[FeatureName]]', row.[[PrimaryKeyParam]]]);
  }

  remove(row: [[EntityPlural]]): void {
    this.confirmationService.confirm({
      header: 'Confirmar exclusão',
      message: `Deseja realmente excluir o registro <strong>${row.[[PrimaryKeyParam]]}</strong>?`,
      icon: 'pi pi-exclamation-triangle',
      acceptButtonProps: { label: 'Excluir', severity: 'danger' },
      rejectButtonProps: { label: 'Cancelar', severity: 'secondary', outlined: true },
      accept: () => {
        this.service.remove(row.[[PrimaryKeyParam]]).subscribe({
          next: () => {
            this.messageService.add({
              severity: 'success',
              summary: 'Excluído',
              detail: 'Registro excluído com sucesso.',
            });

            const currentPage = Math.floor(this.firstRecordIndex() / this.pageSize()) + 1;
            this.loadPage(currentPage);
          },
          error: (error: unknown) => this.showError(error),
        });
      },
    });
  }

  private loadPage(page: number): void {
    this.service.load({
      page,
      pageSize: this.pageSize(),
      sortBy: this.sortField(),
      sortDir:
        this.sortOrder() === 1 ? 'asc' : this.sortOrder() === -1 ? 'desc' : undefined,
      search: this.searchText().trim() || undefined,
    });
  }

  private showError(error: unknown): void {
    const body = (error as { error?: { message?: string; errors?: string[] } | null })?.error;
    const detail = body?.message
      ? `${body.message}${body.errors?.length ? ` — ${body.errors.join(', ')}` : ''}`
      : 'Erro ao processar a solicitação.';

    this.messageService.add({ severity: 'error', summary: 'Erro', detail });
  }
}
