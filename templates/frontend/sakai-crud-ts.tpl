import { Component, OnInit, ViewChild, signal, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ConfirmationService, MessageService } from 'primeng/api';
import { Table, TableModule } from 'primeng/table';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { RippleModule } from 'primeng/ripple';
import { ToastModule } from 'primeng/toast';
import { ToolbarModule } from 'primeng/toolbar';
import { InputTextModule } from 'primeng/inputtext';
import { TextareaModule } from 'primeng/textarea';
import { SelectModule } from 'primeng/select';
import { RadioButtonModule } from 'primeng/radiobutton';
import { InputNumberModule } from 'primeng/inputnumber';
import { DialogModule } from 'primeng/dialog';
import { TagModule } from 'primeng/tag';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { DatePickerModule } from 'primeng/datepicker';
import { CheckboxModule } from 'primeng/checkbox';
import { [[EntityPlural]], [[EntityPlural]]CreateRequest, [[EntityPlural]]UpdateRequest, PagedResult, SelectOption } from './models/[[FeatureName]].model';
import { [[EntityPlural]]Service } from './services/[[FeatureName]].service';

interface Column {
    field: string;
    header: string;
    customExportHeader?: string;
}

interface ExportColumn {
    title: string;
    dataKey: string;
}

@Component({
    selector: 'app-[[FeatureName]]',
    standalone: true,
    imports: [
        CommonModule,
        TableModule,
        FormsModule,
        ButtonModule,
        RippleModule,
        ToastModule,
        ToolbarModule,
        InputTextModule,
        TextareaModule,
        SelectModule,
        RadioButtonModule,
        InputNumberModule,
        DialogModule,
        TagModule,
        InputIconModule,
        IconFieldModule,
        ConfirmDialogModule,
        DatePickerModule,
        CheckboxModule
    ],
    templateUrl: './[[FeatureName]].html',
    styleUrl: './[[FeatureName]].scss',
    providers: [MessageService, ConfirmationService, [[EntityPlural]]Service]
})
export class [[EntityPlural]]Component implements OnInit {
    [[VariableName]]Dialog: boolean = false;

    [[FeatureName]] = signal<[[EntityPlural]][]>([]);

    [[VariableName]]!: [[EntityPlural]];

    selected[[EntityPlural]]!: [[EntityPlural]][] | null;

    submitted: boolean = false;

    statuses!: any[];

    readonly fkOptions = signal<Partial<Record<string, SelectOption[]>>>({});

    @ViewChild('dt') dt!: Table;

    exportColumns!: ExportColumn[];

    cols!: Column[];

    private readonly http = inject(HttpClient);

    // Computed properties for template
    get globalFilterFields(): string[] {
        return [
[[#each ListFields]]            '[[TsProperty]]',
[[/each]]        ];
    }

    get requiredFields(): string[] {
        return [
[[#each EditableFields]][[#if IsRequired]]            '[[TsProperty]]',
[[/if]][[/each]]        ];
    }

    constructor(
        private [[VariableName]]Service: [[EntityPlural]]Service,
        private messageService: MessageService,
        private confirmationService: ConfirmationService
    ) {}

    exportCSV() {
        this.dt.exportCSV();
    }

    ngOnInit() {
        this.loadDemoData();
        this.loadForeignKeyOptions();
    }

    loadDemoData() {
        this.[[VariableName]]Service.load({
            page: 1,
            pageSize: 10,
            sortBy: undefined,
            sortDir: undefined,
            search: undefined
        });

        this.statuses = [
            { label: 'Ativo', value: 'active' },
            { label: 'Inativo', value: 'inactive' },
            { label: 'Pendente', value: 'pending' }
        ];

        this.cols = [
[[#each ListFields]]            { field: '[[TsProperty]]', header: '[[DisplayName]]' },
[[/each]]        ];

        this.exportColumns = this.cols.map((col) => ({ title: col.header, dataKey: col.field }));
    }

    onGlobalFilter(table: Table, event: Event) {
        table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
    }

    openNew() {
        this.[[VariableName]] = {} as [[EntityPlural]];
        this.submitted = false;
        this.[[VariableName]]Dialog = true;
    }

    edit[[EntityName]]([[VariableName]]: [[EntityPlural]]) {
        this.[[VariableName]] = { ...[[VariableName]] };
        this.[[VariableName]]Dialog = true;
    }

    deleteSelected[[EntityPlural]]() {
        this.confirmationService.confirm({
            message: 'Tem certeza que deseja excluir os [[FeatureName]] selecionados?',
            header: 'Confirmar',
            icon: 'pi pi-exclamation-triangle',
            accept: () => {
                this.[[FeatureName]].set(this.[[FeatureName]]().filter((val) => !this.selected[[EntityPlural]]?.includes(val)));
                this.selected[[EntityPlural]] = null;
                this.messageService.add({
                    severity: 'success',
                    summary: 'Sucesso',
                    detail: '[[EntityPlural]] excluídos',
                    life: 3000
                });
            }
        });
    }

    hideDialog() {
        this.[[VariableName]]Dialog = false;
        this.submitted = false;
    }

    delete[[EntityName]]([[VariableName]]: [[EntityPlural]]) {
        this.confirmationService.confirm({
            message: 'Tem certeza que deseja excluir ' + [[VariableName]].[[PrimaryKeyParam]] + '?',
            header: 'Confirmar',
            icon: 'pi pi-exclamation-triangle',
            accept: () => {
                this.[[VariableName]]Service.remove([[VariableName]].[[PrimaryKeyParam]]).subscribe({
                    next: () => {
                        this.[[FeatureName]].set(this.[[FeatureName]]().filter((val) => val.[[PrimaryKeyParam]] !== [[VariableName]].[[PrimaryKeyParam]]));
                        this.[[VariableName]] = {} as [[EntityPlural]];
                        this.messageService.add({
                            severity: 'success',
                            summary: 'Sucesso',
                            detail: '[[EntityName]] excluído',
                            life: 3000
                        });
                    },
                    error: () => {
                        this.messageService.add({
                            severity: 'error',
                            summary: 'Erro',
                            detail: 'Não foi possível excluir o registro.',
                            life: 3000
                        });
                    }
                });
            }
        });
    }

    findIndexById(id: [[PrimaryKeyTsType]]): number {
        let index = -1;
        for (let i = 0; i < this.[[FeatureName]]().length; i++) {
            if (this.[[FeatureName]]()[i].[[PrimaryKeyParam]] === id) {
                index = i;
                break;
            }
        }
        return index;
    }

    createId(): string {
        let id = '';
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (var i = 0; i < 5; i++) {
            id += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return id;
    }

    getSeverity(status: string) {
        switch (status) {
            case 'active':
            case 'Ativo':
            case 'APROVADO':
            case 'CONCLUIDO':
                return 'success';
            case 'pending':
            case 'Pendente':
            case 'EM_ANALISE':
                return 'warn';
            case 'inactive':
            case 'Inativo':
            case 'REJEITADO':
            case 'CANCELADO':
                return 'danger';
            default:
                return 'info';
        }
    }

    save[[EntityName]]() {
        this.submitted = true;
        
        let isValid = true;
        for (const field of this.requiredFields) {
            if (!this.[[VariableName]][field]) {
                isValid = false;
                break;
            }
        }

        if (!isValid) {
            this.messageService.add({
                severity: 'warn',
                summary: 'Atenção',
                detail: 'Preencha todos os campos obrigatórios.',
                life: 3000
            });
            return;
        }

        const _[[FeatureName]] = this.[[FeatureName]]();
        
        if (this.[[VariableName]].[[PrimaryKeyParam]]) {
            // Update
            this.[[VariableName]]Service.update(this.[[VariableName]].[[PrimaryKeyParam]], this.[[VariableName]] as [[EntityPlural]]UpdateRequest).subscribe({
                next: (updated) => {
                    const index = this.findIndexById(this.[[VariableName]].[[PrimaryKeyParam]]);
                    if (index !== -1) {
                        _[[FeatureName]][index] = updated;
                        this.[[FeatureName]].set([..._[[FeatureName]]]);
                    }
                    this.messageService.add({
                        severity: 'success',
                        summary: 'Sucesso',
                        detail: '[[EntityName]] atualizado',
                        life: 3000
                    });
                    this.[[VariableName]]Dialog = false;
                    this.[[VariableName]] = {} as [[EntityPlural]];
                },
                error: () => {
                    this.messageService.add({
                        severity: 'error',
                        summary: 'Erro',
                        detail: 'Não foi possível atualizar o registro.',
                        life: 3000
                    });
                }
            });
        } else {
            // Create
            // Remove auto-increment ID if present
            const { [[PrimaryKeyParam]], ...createDto } = this.[[VariableName]] as any;
            this.[[VariableName]]Service.create(createDto as [[EntityPlural]]CreateRequest).subscribe({
                next: (created) => {
                    this.messageService.add({
                        severity: 'success',
                        summary: 'Sucesso',
                        detail: '[[EntityName]] criado',
                        life: 3000
                    });
                    this.[[FeatureName]].set([..._[[FeatureName]], created]);
                    this.[[VariableName]]Dialog = false;
                    this.[[VariableName]] = {} as [[EntityPlural]];
                },
                error: () => {
                    this.messageService.add({
                        severity: 'error',
                        summary: 'Erro',
                        detail: 'Não foi possível criar o registro.',
                        life: 3000
                    });
                }
            });
        }
    }

    private loadForeignKeyOptions(): void {
[[#each ForeignKeyFields]]        this.http
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
[[/each]]    }

    private forkOptions(options: SelectOption[], field: string): void {
        this.fkOptions.set({ ...this.fkOptions(), [field]: options });
    }

    // Helper methods for form field rendering
[[#each Fields]]
    get [[TsProperty]]Options() {
        return [
[[#each EnumValues]]            { label: '[[.]]', value: '[[.]]' },
[[/each]]        ];
    }
[[/each]]
}