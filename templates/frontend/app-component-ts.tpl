import { Component, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

interface MenuItem {
  label: string;
  icon: string;
  routerLink: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  readonly title = '[[EntityPlural]]';

  readonly menuItems: MenuItem[] = [[[#each MenuItems]]{
    label: '[[Label]]',
    icon: '[[Icon]]',
    routerLink: '[[RouterLink]]',
  },[[/each]]];
}
