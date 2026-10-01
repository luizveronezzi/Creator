:root {
  --app-topbar-bg: #1e293b;
  --app-topbar-bg-hover: #334155;
  --app-surface-bg: #f8fafc;
  --app-card-bg: #ffffff;
  --app-border: #e2e8f0;
  --app-text: #0f172a;
  --app-text-muted: #64748b;
  --app-radius: 8px;
}

* {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  padding: 0;
  height: 100%;
}

body {
  font-family: 'Inter', 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  background: var(--app-surface-bg);
  color: var(--app-text);
  font-size: 0.95rem;
}

.app-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1.5rem;
  background: var(--app-topbar-bg);
  color: #fff;
  padding: 0 1.5rem;
  height: 56px;
}

.app-topbar-brand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 1.05rem;
}

.app-topbar-menu {
  display: flex;
  gap: 0.25rem;
  flex: 1;
}

.app-topbar-menu a {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  color: #cbd5e1;
  text-decoration: none;
  padding: 0.5rem 0.85rem;
  border-radius: var(--app-radius);
  transition: background 0.15s ease, color 0.15s ease;
}

.app-topbar-menu a:hover {
  background: var(--app-topbar-bg-hover);
  color: #fff;
}

.app-topbar-menu a.active {
  background: var(--app-topbar-bg-hover);
  color: #fff;
}

.app-user-name {
  color: #cbd5e1;
  font-size: 0.9rem;
}

.app-main {
  flex: 1;
  padding: 1.5rem;
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
}

.app-footer {
  padding: 1rem 1.5rem;
  color: var(--app-text-muted);
  font-size: 0.85rem;
  border-top: 1px solid var(--app-border);
  background: var(--app-card-bg);
}

.card {
  background: var(--app-card-bg);
  border: 1px solid var(--app-border);
  border-radius: var(--app-radius);
  padding: 1.5rem;
  box-shadow: 0 1px 2px rgb(15 23 42 / 0.05);
}
