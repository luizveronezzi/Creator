import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: '[[FeatureName]]' },
  {
    path: '[[FeatureName]]',
    title: '[[EntityPlural]]',
    loadComponent: () =>
      import('./[[FeatureName]]/pages/[[FeatureName]]-list/[[FeatureName]]-list.component').then(
        (module) => module.[[EntityPlural]]ListComponent,
      ),
  },
  {
    path: '[[FeatureName]]/new',
    title: 'Novo [[EntityName]]',
    loadComponent: () =>
      import('./[[FeatureName]]/pages/[[FeatureName]]-form/[[FeatureName]]-form.component').then(
        (module) => module.[[EntityPlural]]FormComponent,
      ),
  },
  {
    path: '[[FeatureName]]/:id',
    title: 'Alterar [[EntityName]]',
    loadComponent: () =>
      import('./[[FeatureName]]/pages/[[FeatureName]]-form/[[FeatureName]]-form.component').then(
        (module) => module.[[EntityPlural]]FormComponent,
      ),
  },
  { path: '**', redirectTo: '' },
];
