:host {
  display: block;
}

.crud-container {
  padding: 1rem;
}

.crud-toolbar {
  margin-bottom: 1.5rem;
}

.crud-table {
  min-width: 75rem;
}

.crud-dialog {
  min-width: 500px;
}

.crud-dialog .p-dialog-content {
  padding: 1.5rem;
}

.crud-dialog .form-field {
  margin-bottom: 1rem;
}

.crud-dialog .form-field label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.crud-dialog .form-field small {
  display: block;
  margin-top: 0.25rem;
}

.crud-dialog .p-inputtext,
.crud-dialog .p-textarea,
.crud-dialog .p-inputnumber,
.crud-dialog .p-datepicker,
.crud-dialog .p-select {
  width: 100%;
}

.crud-dialog .p-radiobutton,
.crud-dialog .p-checkbox {
  margin-right: 0.5rem;
}

.crud-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.crud-actions .p-button {
  min-width: 2.5rem;
}

@media (max-width: 64rem) {
  .crud-table {
    min-width: 100%;
  }
  
  .crud-dialog {
    min-width: 90vw;
    width: 90vw;
  }
}