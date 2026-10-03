-- =====================================================================
--  MAKELAN KULMA - hallintapaneelin tietokanta
--  Aja tama Supabasen SQL Editorissa (Supabase -> SQL Editor -> New query)
-- =====================================================================

-- ---------- 1. SISALTO ----------
-- Sivun tekstit avain-arvo -pareina. Paneeli muokkaa, sivusto lukee.
create table if not exists public.site_content (
  key         text primary key,
  value       jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

insert into public.site_content (key, value) values
  ('hero',   '{"eyebrow":"Ravintola · Mäkelänkatu 45 · Helsinki","line1":"Pizzat,","line2":"kebabit &","line3":"burgerit","lead":"Rapeat pizzat, mehevät kebabit ja tuhdit burgerit tuoreista raaka-aineista. Tilaa netistä noutona tai kotiinkuljetuksena, tai tule syömään paikan päälle."}'::jsonb),
  ('intro',  '{"body":"Tervetuloa Ravintola Mäkelän Kulmaan, alueen kauneimpaan ja viihtyisimpään ravintolaan. Meillä on ilo tarjota laadukasta palvelua ja herkullista ruokaa tuoreista raaka-aineista."}'::jsonb),
  ('info',   '{"phone":"045 846 1846","email":"info@makelankulma.fi","address":"Mäkelänkatu 45, liiketila 12, 00550 Helsinki"}'::jsonb),
  ('hours',  '{"mon":"10:30–22:00","tue":"10:30–22:00","wed":"10:30–22:00","thu":"10:30–22:00","fri":"10:30–04:00","sat":"10:30–04:00","sun":"10:30–22:00"}'::jsonb),
  ('notice', '{"active":false,"text":""}'::jsonb)
on conflict (key) do nothing;

-- ---------- 2. KAVIJATILASTOT ----------
create table if not exists public.page_views (
  id           bigserial primary key,
  created_at   timestamptz not null default now(),
  day          date not null default (now() at time zone 'Europe/Helsinki')::date,
  path         text not null,
  referrer     text,
  device       text,                         -- mobile | desktop | tablet
  country      text,
  visitor_hash text not null                 -- paivittain vaihtuva tunniste, ei IP-osoitetta
);

create index if not exists page_views_day_idx  on public.page_views (day);
create index if not exists page_views_path_idx on public.page_views (day, path);

create or replace view public.stats_daily with (security_invoker = true) as
select day, count(*) as views, count(distinct visitor_hash) as visitors
from public.page_views group by day order by day desc;

create or replace view public.stats_pages with (security_invoker = true) as
select path, count(*) as views, count(distinct visitor_hash) as visitors
from public.page_views
where day >= (now() at time zone 'Europe/Helsinki')::date - 30
group by path order by views desc;

create or replace view public.stats_devices with (security_invoker = true) as
select coalesce(device,'tuntematon') as device, count(*) as views
from public.page_views
where day >= (now() at time zone 'Europe/Helsinki')::date - 30
group by 1 order by views desc;

create or replace view public.stats_referrers with (security_invoker = true) as
select coalesce(nullif(split_part(split_part(referrer,'://',2),'/',1),''),'suora') as source, count(*) as views
from public.page_views
where day >= (now() at time zone 'Europe/Helsinki')::date - 30
group by 1 order by views desc;

-- ---------- 3. KAYTTOOIKEUDET (RLS) ----------
alter table public.site_content enable row level security;
alter table public.page_views   enable row level security;

drop policy if exists "sisalto luettavissa" on public.site_content;
create policy "sisalto luettavissa" on public.site_content
  for select using (true);

drop policy if exists "henkilokunta hallitsee sisaltoa" on public.site_content;
create policy "henkilokunta hallitsee sisaltoa" on public.site_content
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Tilastot: vain kirjautuneet lukevat. Kirjaus tapahtuu palvelimen kautta (service role).
drop policy if exists "henkilokunta lukee tilastot" on public.page_views;
create policy "henkilokunta lukee tilastot" on public.page_views
  for select using (auth.role() = 'authenticated');

-- ---------- 4. updated_at ----------
create or replace function public.touch_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists site_content_touch on public.site_content;
create trigger site_content_touch before update on public.site_content
  for each row execute function public.touch_updated_at();
