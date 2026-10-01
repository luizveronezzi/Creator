<p-toast></p-toast>

<div class="card">
  <div class="flex flex-wrap align-items-center justify-content-between mb-4">
    <h2 class="m-0 text-xl font-semibold">
      {{ isEdit() ? 'Alterar [[EntityName]]' : 'Novo [[EntityName]]' }}
    </h2>
    <span class="text-color-secondary text-sm">Tabela [[TableName]]</span>
  </div>

  <form [formGroup]="form" (ngSubmit)="save()" novalidate>
    <div class="formgrid grid">
[[#each Fields]]      <div class="field col-12 [[#if IsText]]md:col-12[[else]]md:col-6[[/if]]">
        <label for="[[ParamName]]" class="font-medium">
          [[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500" aria-hidden="true">*</span>[[/if]]
        </label>
[[#if IsInputText]]        <input
          pInputText
          id="[[ParamName]]"
          formControlName="[[ParamName]]"
          class="w-full"[[#if HasMaxLength]]
          maxlength="[[MaxLength]]"[[/if]]
        />
[[/if]][[#if IsTextarea]]        <textarea
          pTextarea
          id="[[ParamName]]"
          formControlName="[[ParamName]]"
          rows="4"
          class="w-full"[[#if HasMaxLength]]
          maxlength="[[MaxLength]]"[[/if]]
        ></textarea>
[[/if]][[#if IsInputNumber]]        <p-inputNumber
          inputId="[[ParamName]]"
          formControlName="[[ParamName]]"
          styleClass="w-full"[[#if IsDecimal]]
          [maxFractionDigits]="[[Scale]]"
          [minFractionDigits]="[[Scale]]"[[/if]]
        />
[[/if]][[#if IsDatePicker]]        <p-datePicker
          inputId="[[ParamName]]"
          formControlName="[[ParamName]]"
          dateFormat="dd/mm/yy"
          [readonlyInput]="true"[[#if IsTime]]
          [timeOnly]="true"
          timeSeparator=":"[[/if]]
          styleClass="w-full"
        />
[[/if]][[#if IsDateTimePicker]]        <p-datePicker
          inputId="[[ParamName]]"
          formControlName="[[ParamName]]"
          dateFormat="dd/mm/yy"
          [showTime]="true"
          hourFormat="24"
          [readonlyInput]="true"
          styleClass="w-full"
        />
[[/if]][[#if IsCheckbox]]        <p-checkbox
          inputId="[[ParamName]]"
          formControlName="[[ParamName]]"
          [binary]="true"
        />
[[/if]][[#if IsSelect]]        <p-select
          inputId="[[ParamName]]"
          formControlName="[[ParamName]]"
          [options]="[[TsProperty]]Options"
          optionLabel="label"
          optionValue="value"
          [showClear]="true"
          styleClass="w-full"
        />
[[/if]][[#if IsSelectForeignKey]]        <p-select
          inputId="[[ParamName]]"
          formControlName="[[ParamName]]"
          [options]="fkOptions()['[[TsProperty]]'] ?? []"
          optionLabel="label"
          optionValue="value"
          [filter]="true"
          [showClear]="true"
          placeholder="Selecione..."
          styleClass="w-full"
        />
[[/if]][[#if HasFormRules]]
        @if (form.get('[[ParamName]]')?.hasError('required') && form.get('[[ParamName]]')?.touched) {
          <small class="p-error block mt-2">[[DisplayName]] é obrigatório.</small>
        }
[[#if HasMaxLength]]
        @if (form.get('[[ParamName]]')?.hasError('maxlength') && form.get('[[ParamName]]')?.touched) {
          <small class="p-error block mt-2">Máximo de [[MaxLength]] caracteres.</small>
        }
[[/if]][[/if]]      </div>
[[/each]]    </div>

    <div class="flex gap-2 mt-4">
      <p-button label="Salvar" icon="pi pi-save" type="submit" [loading]="saving()" />
      <p-button label="Cancelar" icon="pi pi-times" type="button" [text]="true" (onClick)="cancel()" />
    </div>
  </form>
</div>
