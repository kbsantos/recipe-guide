# Recipe Guide

## Architecture

The Recipe Guide is a **read-only consumer** of Store Management recipe data.

- **Store Management is the single source of truth** for recipes.
- Store owns recipe ingredients, inventory mapping, sizes, and preparation steps.
- Recipe Guide syncs the published Store payload and keeps a local cache for offline reading.
- Recipe Guide does not edit, import, export, or locally override recipes.

### Data flow

`Store Management -> Supabase -> get_recipe_guide_catalog() -> Recipe Guide sync -> local cache -> Barista UI`

## Supabase configuration

The ZIP includes a blank `.env` placeholder so the Flutter asset declaration remains valid. Add your project configuration to `.env` before running the app. The `.env.example` file lists the expected keys:

```text
SUPABASE_URL=...
SUPABASE_PUBLISHABLE_KEY=...
SUPABASE_STORE_ID=...
SUPABASE_DEVICE_ID=...
```

Do not put the Supabase service-role key or the Admin PIN in this file. The configured Store account must have permission to read the Store catalog.

## Store migration

Apply:

`supabase/20260930_recipe_guide_sync.sql`

This migration:

- upgrades product recipe rows to size-aware storage when needed;
- adds qualitative `quantity_text` support;
- adds preparation steps per product/size;
- provides the Store recipe management read/write functions;
- provides `get_recipe_guide_catalog()` for the read-only Recipe Guide.

## Offline behavior and manual sync

- The first PIN verification requires internet access.
- After a successful PIN unlock and a successful recipe sync, the app saves the catalog locally and can reopen from that cache while offline.
- Recipe sync is manual only: use the Sync icon on the home screen. There is no automatic sync on app startup or PIN unlock.
- Syncing requires internet access and an active Store session. If sync fails, the last cached catalog remains available.
- A fresh installation with no cached catalog must connect, unlock, and sync once before recipes are available offline.

## Secure PIN login

The Recipe Guide PIN is verified server-side by the `recipe-guide-pin-login` Supabase Edge Function. The PIN is **not** compiled into the Flutter client. After successful verification, the function creates a Supabase session for the configured Store account, so existing Store-side RLS and the `get_recipe_guide_catalog()` RPC remain in force. Email/password login and saved email/password settings have been removed from the app.

Deploy the database migration and Edge Function from the project root:

```bash
supabase db push
supabase functions deploy recipe-guide-pin-login
supabase secrets set RECIPE_GUIDE_ADMIN_PIN=YOUR_4_TO_8_DIGIT_PIN RECIPE_GUIDE_ADMIN_EMAIL=store-authorized-user@example.com PIN_RATE_LIMIT_SALT=YOUR_LONG_RANDOM_SALT
```

The Edge Function also requires the project's standard `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` secrets. Supabase provides these in hosted Edge Functions; do not put the service-role key or PIN in `.env`, Dart code, or client build arguments. `RECIPE_GUIDE_ADMIN_EMAIL` must be an existing, confirmed Supabase user that already has permission to read the Store catalog. The function limits each hashed client IP to eight attempts per 15 minutes using `recipe_guide_pin_attempts`.

PIN verification requires network access on first use. After a successful online unlock, the app stores a local unlocked marker; on later launches it can open offline only when a cached catalog also exists. This is a local convenience for offline use, not a replacement for server-side PIN verification on first unlock. Sync remains manual and requires internet access plus an active Store session.
