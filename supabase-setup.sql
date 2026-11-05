create table if not exists public.copa_lince_state (
    id smallint primary key check (id = 1),
    state jsonb not null,
    updated_at timestamptz not null default now()
);

alter table public.copa_lince_state enable row level security;

grant select on public.copa_lince_state to anon, authenticated;
grant insert, update on public.copa_lince_state to authenticated;

drop policy if exists "Copa state is public to read" on public.copa_lince_state;
create policy "Copa state is public to read"
    on public.copa_lince_state
    for select
    to anon, authenticated
    using (true);

drop policy if exists "Only STAFF can create Copa state" on public.copa_lince_state;
create policy "Only STAFF can create Copa state"
    on public.copa_lince_state
    for insert
    to authenticated
    with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'staff');

drop policy if exists "Only STAFF can update Copa state" on public.copa_lince_state;
create policy "Only STAFF can update Copa state"
    on public.copa_lince_state
    for update
    to authenticated
    using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'staff')
    with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'staff');

do $$
begin
    if not exists (
        select 1
        from pg_publication_tables
        where pubname = 'supabase_realtime'
          and schemaname = 'public'
          and tablename = 'copa_lince_state'
    ) then
        alter publication supabase_realtime add table public.copa_lince_state;
    end if;
end
$$;
