import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { CheckboxModule } from 'primeng/checkbox';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { TextareaModule } from 'primeng/textarea';
import { ToastModule } from 'primeng/toast';
import {
  [[EntityPlural]],
  [[EntityPlural]]CreateRequest,
  [[EntityPlural]]UpdateRequest,
  PagedResult,
  SelectOption,
} from '../../models/[[FeatureName]].model';
import { [[EntityPlural]]Service } from '../../services/[[FeatureName]].service';

/** Formulário reativo de inclusão/alteração de [[EntityPlural]] gerado a partir dos metadados. */
@Component({
  selector: 'app-[[FeatureName]]-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ToastModule,
    ButtonModule,
    InputTextModule,
    TextareaModule,
    InputNumberModule,
    DatePickerModule,
    CheckboxModule,
    SelectModule,
  ],
  templateUrl: './[[FeatureName]]-form.component.html',
  styleUrl: './[[FeatureName]]-form.component.scss',
})
export class [[EntityPlural]]FormComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly http = inject(HttpClient);
  private readonly messageService = inject(MessageService);

  readonly service = inject([[EntityPlural]]Service);
  readonly form: FormGroup;
  readonly isEdit = signal(false);
  readonly saving = signal(false);
  readonly fkOptions = signal<Partial<Record<string, SelectOption[]>>>({});
[[#each EnumFields]]
  readonly [[TsProperty]]Options: SelectOption[] = [[[#each EnumValues]]{ label: '[[.]]', value: '[[.]]' },[[/each]]];
[[/each]]

  constructor() {
    this.form = this.fb.group({
[[#each Fields]]      [[ParamName]]: [[#if HasFormRules]][[[#if IsBoolean]]false[[else]]null[[/if]], [[#if IsRequired]]Validators.required,[[/if]][[#if HasMaxLength]]Validators.maxLength([[MaxLength]]),[[/if]]][[else]][[#if IsAutoIncrement]]{ value: null, disabled: true }[[else]][[#if IsBoolean]]false[[else]]null[[/if]][[/if]][[/if]],
[[/each]]    });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');

    if (id) {
      this.isEdit.set(true);
      this.service.get([[#if PrimaryKeyIsNumericTs]]Number(id)[[else]]id[[/if]]).subscribe({
        next: (entity) => this.form.patchValue(this.toFormValues(entity)),
        error: () =>
          this.messageService.add({
            severity: 'error',
            summary: 'Erro',
            detail: 'Não foi possível carregar o registro.',
          }),
      });
[[#if HasAssignedPrimaryKey]]
      this.form.get('[[PrimaryKeyParam]]')?.disable();[[/if]]
    }

    this.loadForeignKeyOptions();
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      this.messageService.add({
        severity: 'warn',
        summary: 'Atenção',
        detail: 'Verifique os campos destacados.',
      });
      return;
    }

    const payload = this.buildPayload();
    const id = this.route.snapshot.paramMap.get('id');

    this.saving.set(true);
    const request$ = id
      ? this.service.update([[#if PrimaryKeyIsNumericTs]]Number(id)[[else]]id[[/if]], payload as unknown as [[EntityPlural]]UpdateRequest)
      : this.service.create(payload as unknown as [[EntityPlural]]CreateRequest);

    request$.subscribe({
      next: () => {
        this.saving.set(false);
        this.messageService.add({
          severity: 'success',
          summary: 'Salvo',
          detail: 'Registro salvo com sucesso.',
        });
        void this.router.navigate(['/[[FeatureName]]']);
      },
      error: (error: unknown) => {
        this.saving.set(false);
        this.showError(error);
      },
    });
  }

  cancel(): void {
    void this.router.navigate(['/[[FeatureName]]']);
  }

  private loadForeignKeyOptions(): void {
[[#each ForeignKeyFields]]    this.http
      .get<PagedResult<Record<string, unknown>>>('/api/[[ForeignKeyRoute]]')
      .subscribe({
        next: (page) => {
          const options: SelectOption[] = page.items.map((item) => ({
            label: String(item['[[ForeignKeyLabelProperty]]'] ?? ''),
            value: item['[[ForeignKeyIdProperty]]'],
          }));
          this.forkOptions(options, '[[TsProperty]]');
        },
        error: () => undefined,
      });
[[/each]]  }

  private forkOptions(options: SelectOption[], field: string): void {
    this.fkOptions.set({ ...this.fkOptions(), [field]: options });
  }

  private toFormValues(entity: [[EntityPlural]]): Record<string, unknown> {
    const values: Record<string, unknown> = { ...entity };
[[#each Fields]][[#if NeedsDateConversion]]
    values['[[TsProperty]]'] = this.restoreDateOnly(values['[[TsProperty]]']);[[/if]][[#if NeedsDateTimeConversion]]
    values['[[TsProperty]]'] = this.restoreDateTime(values['[[TsProperty]]']);[[/if]][[#if NeedsTimeConversion]]
    values['[[TsProperty]]'] = this.restoreTime(values['[[TsProperty]]']);[[/if]]
[[/each]]    return values;
  }

  private buildPayload(): Record<string, unknown> {
    const payload: Record<string, unknown> = { ...this.form.value };
[[#each Fields]][[#if NeedsDateConversion]]
    payload['[[TsProperty]]'] = this.formatDateOnly(payload['[[TsProperty]]']);[[/if]][[#if NeedsDateTimeConversion]]
    payload['[[TsProperty]]'] = this.formatDateTime(payload['[[TsProperty]]']);[[/if]][[#if NeedsTimeConversion]]
    payload['[[TsProperty]]'] = this.formatTime(payload['[[TsProperty]]']);[[/if]]
[[/each]]    return payload;
  }

  private formatDateOnly(value: unknown): unknown {
    if (!(value instanceof Date)) {
      return value;
    }

    const month = String(value.getMonth() + 1).padStart(2, '0');
    const day = String(value.getDate()).padStart(2, '0');
    return `${value.getFullYear()}-${month}-${day}`;
  }

  private formatDateTime(value: unknown): unknown {
    if (!(value instanceof Date)) {
      return value;
    }

    const date = this.formatDateOnly(value) as string;
    const hours = String(value.getHours()).padStart(2, '0');
    const minutes = String(value.getMinutes()).padStart(2, '0');
    const seconds = String(value.getSeconds()).padStart(2, '0');
    return `${date}T${hours}:${minutes}:${seconds}`;
  }

  private formatTime(value: unknown): unknown {
    if (!(value instanceof Date)) {
      return value;
    }

    const hours = String(value.getHours()).padStart(2, '0');
    const minutes = String(value.getMinutes()).padStart(2, '0');
    const seconds = String(value.getSeconds()).padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }

  private restoreDateOnly(value: unknown): unknown {
    if (typeof value !== 'string' || !value) {
      return value;
    }

    const [year, month, day] = value.split('-').map((part) => Number(part));
    return new Date(year, (month || 1) - 1, day || 1);
  }

  private restoreDateTime(value: unknown): unknown {
    if (typeof value !== 'string' || !value) {
      return value;
    }

    return new Date(value);
  }

  private restoreTime(value: unknown): unknown {
    if (typeof value !== 'string' || !value) {
      return value;
    }

    const [hours, minutes, seconds] = value.split(':').map((part) => Number(part));
    const date = new Date();
    date.setHours(hours || 0, minutes || 0, seconds || 0, 0);
    return date;
  }

  private showError(error: unknown): void {
    const body = (error as { error?: { message?: string; errors?: string[] } | null })?.error;
    const detail = body?.message
      ? `${body.message}${body.errors?.length ? ` — ${body.errors.join(', ')}` : ''}`
      : 'Erro ao processar a solicitação.';

    this.messageService.add({ severity: 'error', summary: 'Erro', detail });
  }
}
