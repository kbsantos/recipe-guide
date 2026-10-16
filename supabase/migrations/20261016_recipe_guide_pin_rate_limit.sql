-- Rate-limit PIN attempts for the Recipe Guide PIN login Edge Function.
-- Only the Edge Function's service-role key may access this table.
create table if not exists public.recipe_guide_pin_attempts (
  id bigint generated always as identity primary key,
  ip_hash text not null,
  attempted_at timestamptz not null default now()
);

create index if not exists idx_recipe_guide_pin_attempts_ip_time
  on public.recipe_guide_pin_attempts (ip_hash, attempted_at desc);

alter table public.recipe_guide_pin_attempts enable row level security;
revoke all on public.recipe_guide_pin_attempts from anon, authenticated, public;
grant all on public.recipe_guide_pin_attempts to service_role;

-- Opportunistic cleanup is also performed by the Edge Function's normal traffic;
-- this index keeps the rate-limit query efficient.
