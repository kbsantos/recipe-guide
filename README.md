# Bigger Brew Barista Recipe Guide

## Architecture

The Recipe Guide is a **read-only consumer** of Store Management recipe data.

- **Store Management is the single source of truth** for recipes.
- Store owns recipe ingredients, inventory mapping, sizes, and preparation steps.
- Recipe Guide syncs the published Store payload and keeps a local cache for offline reading.
- Recipe Guide does not edit, import, export, or locally override recipes.

### Data flow

`Store Management -> Supabase -> get_recipe_guide_catalog() -> Recipe Guide sync -> local cache -> Barista UI`

## Supabase configuration

Copy `.env.example` to `.env` and provide:

```text
SUPABASE_URL=...
SUPABASE_PUBLISHABLE_KEY=...
```

The signed-in user must have a Store Management `store_id` in Supabase `app_metadata`.

## Store migration

Apply:

`supabase/20260930_recipe_guide_sync.sql`

This migration:

- upgrades product recipe rows to size-aware storage when needed;
- adds qualitative `quantity_text` support;
- adds preparation steps per product/size;
- provides the Store recipe management read/write functions;
- provides `get_recipe_guide_catalog()` for the read-only Recipe Guide.

## Offline behavior

After a successful sync, the latest Store payload is cached locally. If the Store endpoint is temporarily unavailable, the Recipe Guide opens from that cache.

A new installation without a successful first sync cannot display recipes because there is no bundled recipe source.
