-- Run this once in your Supabase project's SQL editor (Dashboard -> SQL Editor -> New query).

create table sightings (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  floor smallint not null check (floor between 1 and 10),
  reporter_name text
);

alter table sightings enable row level security;

create policy "public read"
  on sightings for select
  using (true);

create policy "public insert"
  on sightings for insert
  with check (true);

-- Realtime: enable the "Realtime" toggle for the `sightings` table in
-- Dashboard -> Database -> Replication, so the app gets live updates.
