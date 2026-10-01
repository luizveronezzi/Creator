<div class="app-wrapper">
  <header class="app-topbar">
    <div class="app-topbar-brand">
      <i class="pi pi-code"></i>
      <span class="app-brand-title">Gerador-Codigo</span>
    </div>
    <nav class="app-topbar-menu">
      @for (item of menuItems; track item.label) {
        <a [routerLink]="item.routerLink" routerLinkActive="active">
          <i [class]="item.icon"></i>
          <span>{{ item.label }}</span>
        </a>
      }
    </nav>
    <div class="app-topbar-actions">
      <span class="app-user-name">{{ title }}</span>
    </div>
  </header>

  <main class="app-main">
    <router-outlet />
  </main>

  <footer class="app-footer">
    <span>Gerado por Gerador-Codigo — tabela [[TableName]]</span>
  </footer>
</div>
