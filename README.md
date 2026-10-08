# Snack Cart Tracker

A hospital snack-cart location tracker. Staff tap the floor they spotted the
cart on; everyone else sees it update live. No passwords — just enter your
name once and the browser remembers it.

## 1. Create a Supabase project (free)

1. Go to https://supabase.com, sign in, and click **New project**.
2. Once it's created, open **SQL Editor** and run the contents of
   [`supabase/schema.sql`](supabase/schema.sql), then
   [`supabase/migration_rewards_comments.sql`](supabase/migration_rewards_comments.sql)
   (adds the 5-minute reporting cooldown, comments, and reactions).
3. Open **Database → Replication** and turn on the **Realtime** toggle for
   the `sightings`, `comments`, and `comment_reactions` tables (so updates
   push live instead of waiting on a poll).
4. Open **Project Settings → API** and copy:
   - **Project URL**
   - **anon public** key (NOT the `service_role` key — that one must stay secret)

## 2. Configure the app

Open [`index.html`](index.html), find the `CONFIG` block near the top of the
`<script type="module">` tag, and paste in your values:

```js
const CONFIG = {
  SUPABASE_URL:      'https://xxxxxxxx.supabase.co',
  SUPABASE_ANON_KEY: 'eyJ...',
  ...
};
```

The anon key is safe to ship in a public static site — it only grants the
access allowed by the Row Level Security policies in `schema.sql` (public
read/insert on the `sightings` table, nothing else in your Supabase project).

## 3. Deploy to GitHub Pages (free)

```bash
cd snack-cart-portal
git init
git add .
git commit -m "Initial commit"
```

Then on github.com, create a new **public** repo (e.g. `snack-cart-portal`),
and push:

```bash
git remote add origin https://github.com/<your-username>/snack-cart-portal.git
git branch -M main
git push -u origin main
```

Finally, in the repo's **Settings → Pages**, set the source to the `main`
branch (`/` root), save, and your app will be live at
`https://<your-username>.github.io/snack-cart-portal/` within a minute or two.

## How it works

- **Identity ("log in")**: on first visit, a modal asks for your name and
  saves it to `localStorage` on your browser — no account, no password.
  Tap the chip in the header any time to change it.
- **Data**: floor reports are written to a `sightings` table in Supabase and
  broadcast to every open tab/device via Supabase Realtime.
- **Rewards**: each report earns 1 point (counted directly from your past
  `sightings` rows — no separate score to get out of sync) and unlocks
  badges at 1 / 5 / 15 / 30 / 60 points (see the `BADGES` constant in
  `index.html` to change the tiers). After reporting, there's a 5-minute
  cooldown before you can report again — enforced both in the UI and by a
  database policy, so it can't be bypassed by refreshing the page.
- **Comments & reactions**: an open comment thread under the timeline, with
  five emoji reactions per comment. Anyone can post or react using the same
  name-only identity as reporting.
- **Everything is static**: `index.html` is the whole app. No server to run,
  no build step — just open the file or host it anywhere that serves static
  files.
