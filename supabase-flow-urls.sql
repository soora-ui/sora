-- ============================================================
--  sora studio — привязка flow-страниц к оставшимся 4 работам
--  Выполни ОДИН РАЗ в Supabase → SQL Editor → New query → Run.
--  (Файлы okno-flow.html и т.д. уже лежат в репозитории рядом с index.html.)
-- ============================================================

update public.works set flow_url = 'okno-flow.html'       where title = 'okno';
update public.works set flow_url = 'team-flow.html'       where title = 'Team Analytics';
update public.works set flow_url = 'smeta-flow.html'      where title = 'Смета PDF';
update public.works set flow_url = 'automation-flow.html' where title = 'Личная автоматизация';

-- Проверка: у всех 8 работ должен быть flow_url
-- select title, flow_url from public.works order by position;
