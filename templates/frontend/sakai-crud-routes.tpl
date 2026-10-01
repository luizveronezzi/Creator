import { Routes } from '@angular/router';

export default [
    { 
        path: '', 
        loadComponent: () => import('./[[FeatureName]]').then(m => m.[[EntityPlural]]Component),
        title: '[[EntityPlural]]'
    },
    { path: '**', redirectTo: '' }
] as Routes;