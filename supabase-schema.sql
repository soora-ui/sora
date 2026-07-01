-- ============================================================
--  sora studio — схема портфолио для Supabase
--  Выполни этот SQL в Supabase: Dashboard → SQL Editor → New query → Run
-- ============================================================

-- 1) ТАБЛИЦА РАБОТ (КЕЙСОВ) -----------------------------------
create table if not exists public.works (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  position    int  not null default 0,          -- порядок на сайте (меньше = выше)
  published   boolean not null default true,    -- черновик / опубликовано
  title       text not null,
  tag         text,                             -- короткая метка карточки, напр. "saas · booking"
  short_desc  text,                             -- описание на карточке
  long_desc   text,                             -- полный текст кейса
  year        int,                              -- год проекта
  stack       text[] not null default '{}',     -- технологии / теги
  role        text,                             -- роль / что сделано
  link        text,                             -- ссылка на проект
  cover_url   text,                             -- обложка
  gallery     text[] not null default '{}',     -- галерея изображений
  flow_url    text                              -- страница с разбором флоу (открывается поп-апом)
);

-- Миграция для уже существующей таблицы (если создавалась до появления flow_url)
alter table public.works add column if not exists flow_url text;

alter table public.works enable row level security;

-- Публичное чтение — только опубликованные работы
drop policy if exists "public read published" on public.works;
create policy "public read published"
  on public.works for select
  to anon
  using (published = true);

-- Авторизованный админ — полный доступ
drop policy if exists "auth read all" on public.works;
create policy "auth read all" on public.works for select to authenticated using (true);

drop policy if exists "auth insert" on public.works;
create policy "auth insert" on public.works for insert to authenticated with check (true);

drop policy if exists "auth update" on public.works;
create policy "auth update" on public.works for update to authenticated using (true) with check (true);

drop policy if exists "auth delete" on public.works;
create policy "auth delete" on public.works for delete to authenticated using (true);


-- 2) ХРАНИЛИЩЕ ИЗОБРАЖЕНИЙ ------------------------------------
insert into storage.buckets (id, name, public)
values ('works', 'works', true)
on conflict (id) do nothing;

-- Публичное чтение файлов
drop policy if exists "public read works files" on storage.objects;
create policy "public read works files"
  on storage.objects for select
  to anon
  using (bucket_id = 'works');

-- Загрузка / изменение / удаление файлов — только админ
drop policy if exists "auth upload works files" on storage.objects;
create policy "auth upload works files"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'works');

drop policy if exists "auth update works files" on storage.objects;
create policy "auth update works files"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'works');

drop policy if exists "auth delete works files" on storage.objects;
create policy "auth delete works files"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'works');


-- 3) СИД: ТЕКУЩИЕ 6 РАБОТ -------------------------------------
--  Выполняется один раз. Если работы уже есть — этот блок можно пропустить.
insert into public.works (position, title, tag, short_desc, year, stack, role)
values
  (0, 'okno',                 'saas · booking',    'Система записи и управления клиентами для beauty-мастеров. Рейтинг надёжности, предоплаты через ЮKassa, AI-консультации.', 2025, '{React,Supabase,ЮKassa}', 'Идея, разработка, запуск'),
  (1, 'Tarot Bot',            'telegram · bot',    'Бот с платёжной системой. Персонализированные расклады, подписки, Telegram Payments.',                                     2024, '{Python,Telegram,Payments}', 'Разработка'),
  (2, 'Team Analytics',       'analytics · hr',    'Бот для расчёта выплат и аналитики команды. Автоматизация операционки.',                                                   2024, '{Node.js,PostgreSQL}', 'Разработка'),
  (3, 'Смета PDF',            'react · pdf',       'MVP для строительных бригад — быстрое создание смет с экспортом в PDF.',                                                    2024, '{React,Vite}', 'MVP'),
  (4, 'Transport',            'tracking',          'Трекинг транспорта в реальном времени.',                                                                                   2023, '{Node.js}', 'Разработка'),
  (5, 'Личная автоматизация', 'ai · automation',   'Инструменты для автоматизации документооборота и персональных процессов. AI-агенты для рутинных задач.',                   2025, '{Python,AI}', 'Автоматизация')
on conflict do nothing;


-- 4) FLOW-СТРАНИЦЫ: привязка к кейсам --------------------------
--  Выполняется один раз. Привязывает готовые flow-страницы (лежат
--  рядом с index.html в репозитории) к соответствующим работам
--  и добавляет 2 новых кейса, под которые эти flow были сделаны.
update public.works set flow_url = 'diplom-flow.html'   where title = 'Transport';
update public.works set flow_url = 'gracessa-flow.html' where title = 'Tarot Bot';

insert into public.works (position, title, tag, short_desc, year, stack, role, flow_url)
values
  (6, 'TraffBot',       'telegram · bot', 'Личный кабинет для команды трафферов — баланс, вывод в SOL и заявки, которые админ разбирает в два клика.', 2025, '{Python,Telegram,Solana}', 'Разработка', 'traff-flow.html'),
  (7, 'WB Price Scanner', 'parser · bot', 'Фоновый бот проходит по Wildberries раз в минуту в поиске техники Apple дешевле рынка и мгновенно пишет в Telegram.', 2025, '{Python,Parsing,Telegram}', 'Разработка', 'parser-flow.html')
on conflict do nothing;
