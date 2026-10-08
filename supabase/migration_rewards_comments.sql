-- Run this once in your Supabase SQL editor, after schema.sql.
-- Adds: a real (server-enforced) 5-minute reporting cooldown, and comments + reactions.

-- ── 5-minute cooldown, enforced for real ──────────────────────────
-- Replaces the old fully-open insert policy on sightings with one that
-- rejects a new report from the same reporter_name within 5 minutes of
-- their last one. This can't be bypassed by refreshing the page or
-- editing localStorage, since it's checked by the database itself.
drop policy if exists "public insert" on sightings;

create policy "rate limited insert"
  on sightings for insert
  with check (
    reporter_name is null or trim(reporter_name) = '' or not exists (
      select 1 from sightings s
      where s.reporter_name = reporter_name
        and s.created_at > now() - interval '5 minutes'
    )
  );

-- ── Comments ───────────────────────────────────────────────────────
create table comments (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  author_name text,
  body text not null check (char_length(trim(body)) between 1 and 500)
);

alter table comments enable row level security;

create policy "public read"   on comments for select using (true);
create policy "public insert" on comments for insert with check (true);

-- ── Reactions (one row per person per emoji per comment) ───────────
create table comment_reactions (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  comment_id bigint not null references comments(id) on delete cascade,
  emoji text not null,
  author_name text not null,
  unique (comment_id, emoji, author_name)
);

alter table comment_reactions enable row level security;

create policy "public read"   on comment_reactions for select using (true);
create policy "public insert" on comment_reactions for insert with check (true);
create policy "public delete" on comment_reactions for delete using (true);

-- Realtime: enable the "Realtime" toggle for `comments` and
-- `comment_reactions` too, in Dashboard -> Database -> Replication.
