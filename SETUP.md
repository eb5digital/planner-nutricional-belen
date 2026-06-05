# Planner Nutricional · Belén Tauzin Romeo — Guía de Setup

## 1. Clerk (autenticación)

1. Entrá a [dashboard.clerk.com](https://dashboard.clerk.com)
2. Creá una nueva aplicación → elegí `Email + Password`
3. Copiá la **Publishable Key** (`pk_test_...`)
4. En `index.html` y `admin.html`, reemplazá `pk_test_REPLACE_WITH_YOUR_KEY`

---

## 2. Supabase (base de datos)

1. Entrá a [supabase.com](https://supabase.com) y creá un proyecto nuevo
2. En el proyecto, andá a **SQL Editor → New Query**
3. Pegá el contenido de `schema.sql` y ejecutalo
4. Andá a **Settings → API** y copiá:
   - **Project URL** → reemplazá `https://REPLACE.supabase.co`
   - **anon (public) key** → reemplazá `REPLACE_ANON_KEY`
5. Hacé esos reemplazos en **ambos** archivos: `index.html` y `admin.html`

---

## 3. Email del admin

En `admin.html`, buscá:
```javascript
const ADMIN_EMAIL = 'eb5marketingdigital@gmail.com';
```
Reemplazá con el email real de Belén (el que use para registrarse en Clerk).

---

## 4. GitHub

```bash
cd "planner-belen"
git init
git add .
git commit -m "Initial commit: planner nutricional"
gh repo create planner-nutricional-belen --public --source=. --push
```

---

## 5. Deploy en Vercel

1. Entrá a [vercel.com](https://vercel.com) → **Add New Project**
2. Importá el repo de GitHub
3. Deploy automático (no necesita build command — es HTML puro)
4. La URL pública será tipo: `https://planner-nutricional-belen.vercel.app`

---

## 6. Clerk Webhook (opcional pero recomendado)

Para capturar registros en tiempo real:
1. En Clerk Dashboard → **Webhooks → Add endpoint**
2. URL: `https://tu-dominio.vercel.app/api/webhook` *(requiere una Edge Function en Vercel)*
3. Eventos: `user.created`, `user.updated`

Sin el webhook, los pacientes se registran en Supabase cuando abren el planner por primera vez.

---

## Archivos del proyecto

| Archivo | Descripción |
|---|---|
| `index.html` | App para pacientes (Clerk + Supabase sync + localStorage) |
| `admin.html` | Dashboard para Belén (analytics, lista de pacientes) |
| `schema.sql` | SQL para crear tablas en Supabase |
| `SETUP.md` | Esta guía |

---

## URL estructura

- `/index.html` → App pacientes (requiere login con Clerk)
- `/admin.html` → Dashboard Belén (solo accesible con su email)
