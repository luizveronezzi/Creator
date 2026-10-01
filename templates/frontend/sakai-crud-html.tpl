<p-toolbar styleClass="mb-6">
    <ng-template #start>
        <p-button label="Novo" icon="pi pi-plus" severity="secondary" class="mr-2" (onClick)="openNew()" />
        <p-button severity="secondary" label="Excluir Selecionados" icon="pi pi-trash" outlined (onClick)="deleteSelected[[EntityPlural]]()" [disabled]="!selected[[EntityPlural]] || !selected[[EntityPlural]].length" />
    </ng-template>

    <ng-template #end>
        <p-button label="Exportar CSV" icon="pi pi-upload" severity="secondary" (onClick)="exportCSV()" />
    </ng-template>
</p-toolbar>

<p-table
    #dt
    [value]="[[FeatureName]]()"
    [rows]="10"
    [columns]="cols"
    [paginator]="true"
    [globalFilterFields]="globalFilterFields"
    [tableStyle]="{ 'min-width': '75rem' }"
    [(selection)]="selected[[EntityPlural]]"
    [rowHover]="true"
    dataKey="[[PrimaryKeyParam]]"
    currentPageReportTemplate="Mostrando {first} a {last} de {totalRecords} [[FeatureName]]"
    [showCurrentPageReport]="true"
    [rowsPerPageOptions]="[10, 20, 30]"
>
    <ng-template #caption>
        <div class="flex items-center justify-between">
            <h5 class="m-0">Gerenciar [[EntityPlural]]</h5>
            <p-iconfield>
                <p-inputicon styleClass="pi pi-search" />
                <input pInputText type="text" (input)="onGlobalFilter(dt, $event)" placeholder="Buscar..." />
            </p-iconfield>
        </div>
    </ng-template>
    <ng-template #header>
        <tr>
            <th style="width: 3rem">
                <p-tableHeaderCheckbox />
            </th>
[[#each ListFields]]            <th pSortableColumn="[[TsProperty]]" style="min-width: 12rem">
                <div class="flex justify-between items-center">
                    [[DisplayName]]
                    <p-sortIcon field="[[TsProperty]]" />
                </div>
            </th>
[[/each]]            <th style="min-width: 8rem"></th>
        </tr>
    </ng-template>
    <ng-template #body let-item>
        <tr>
            <td style="width: 3rem">
                <p-tableCheckbox [value]="item" />
            </td>
[[#each ListFields]][[#if IsBoolean]]            <td style="min-width: 8rem">
                <p-tag [value]="item.[[TsProperty]] ? 'Sim' : 'Não'" [severity]="item.[[TsProperty]] ? 'success' : 'danger'" />
            </td>
[[/if]][[#if IsEnum]]            <td style="min-width: 10rem">
                <p-tag [value]="item.[[TsProperty]]" [severity]="getSeverity(item.[[TsProperty]])" />
            </td>
[[/if]][[#if IsDecimal]]            <td style="min-width: 10rem">
                {{ item.[[TsProperty]] | number: '1.2-2' }}
            </td>
[[/if]][[#if IsDate]]            <td style="min-width: 10rem">
                {{ item.[[TsProperty]] | date: 'dd/MM/yyyy' }}
            </td>
[[/if]][[#if IsFullDateTime]]            <td style="min-width: 12rem">
                {{ item.[[TsProperty]] | date: 'dd/MM/yyyy HH:mm' }}
            </td>
[[/if]][[#if IsPlainListField]]            <td style="min-width: 12rem">
                {{ item.[[TsProperty]] }}
            </td>
[[/if]][[/each]]            <td style="min-width: 8rem">
                <p-button icon="pi pi-pencil" class="mr-2" [rounded]="true" [outlined]="true" (click)="edit[[EntityName]](item)" />
                <p-button icon="pi pi-trash" severity="danger" [rounded]="true" [outlined]="true" (click)="delete[[EntityName]](item)" />
            </td>
        </tr>
    </ng-template>
</p-table>

<p-dialog [(visible)]="[[VariableName]]Dialog" [style]="{ width: '500px' }" header="Detalhes do [[EntityName]]" [modal]="true">
    <ng-template #content>
        <div class="flex flex-col gap-6">
[[#each Fields]][[#if IsPrimaryKey]][[#if IsAutoIncrement]]
            <!-- [[DisplayName]] (auto) -->
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]]</label>
                <input type="text" pInputText id="[[ParamName]]" [(ngModel)]="[[VariableName]].[[TsProperty]]" disabled fluid />
                <small class="text-gray-500">Gerado automaticamente</small>
            </div>
[[/if]][[/if]][[#if IsInputText]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <input type="text" pInputText id="[[ParamName]]" [(ngModel)]="[[VariableName]].[[TsProperty]]" required fluid [[#if HasMaxLength]]maxlength="[[MaxLength]]"[[/if]] />
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[#if IsTextarea]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <textarea id="[[ParamName]]" pTextarea [(ngModel)]="[[VariableName]].[[TsProperty]]" required rows="3" cols="20" fluid [[#if HasMaxLength]]maxlength="[[MaxLength]]"[[/if]]></textarea>
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[#if IsInputNumber]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <p-inputnumber id="[[ParamName]]" [(ngModel)]="[[VariableName]].[[TsProperty]]" [[#if IsDecimal]]mode="currency" currency="BRL" locale="pt-BR"[[/if]] fluid />
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[#if IsDatePicker]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <p-datePicker inputId="[[ParamName]]" [(ngModel)]="[[VariableName]].[[TsProperty]]" dateFormat="dd/mm/yy" [readonlyInput]="true" styleClass="w-full" [[#if IsRequired]]required[[/if]] />
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[#if IsDateTimePicker]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <p-datePicker inputId="[[ParamName]]" [(ngModel)]="[[VariableName]].[[TsProperty]]" dateFormat="dd/mm/yy" [showTime]="true" hourFormat="24" [readonlyInput]="true" styleClass="w-full" [[#if IsRequired]]required[[/if]] />
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[#if IsCheckbox]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]]</label>
                <p-checkbox inputId="[[ParamName]]" [(ngModel)]="[[VariableName]].[[TsProperty]]" [binary]="true" />
            </div>
[[/if]][[#if IsSelect]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <p-select [(ngModel)]="[[VariableName]].[[TsProperty]]" inputId="[[ParamName]]" [options]="[[TsProperty]]Options" optionLabel="label" optionValue="value" placeholder="Selecione..." fluid [[#if IsRequired]]required[[/if]] />
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[#if IsSelectForeignKey]]
            <div>
                <label for="[[ParamName]]" class="block font-bold mb-3">[[DisplayName]][[#if IsRequiredForm]] <span class="text-red-500">*</span>[[/if]]</label>
                <p-select [(ngModel)]="[[VariableName]].[[TsProperty]]" inputId="[[ParamName]]" [options]="fkOptions()['[[TsProperty]]'] ?? []" optionLabel="label" optionValue="value" [filter]="true" [showClear]="true" placeholder="Selecione..." styleClass="w-full" [[#if IsRequired]]required[[/if]] />
                [[#if HasFormRules]]<small class="text-red-500" *ngIf="submitted && ![[VariableName]].[[TsProperty]]">[[DisplayName]] é obrigatório.</small>[[/if]]
            </div>
[[/if]][[/each]]        </div>
    </ng-template>

    <ng-template #footer>
        <p-button label="Cancelar" icon="pi pi-times" text (click)="hideDialog()" />
        <p-button label="Salvar" icon="pi pi-check" (click)="save[[EntityName]]()" />
    </ng-template>
</p-dialog>

<p-confirmdialog [style]="{ width: '450px' }" />