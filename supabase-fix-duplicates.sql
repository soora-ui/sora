-- ============================================================
--  sora studio — удаление дублей работ + защита от повторов
--  Выполни ОДИН РАЗ в Supabase → SQL Editor → New query → Run.
--
--  Почему появились дубли: сид-блок в supabase-schema.sql не имел
--  уникального ограничения, поэтому при повторном запуске схемы
--  работы вставлялись заново (по 2 копии каждой из 6 исходных).
-- ============================================================

-- 1) Удалить дубли, оставив самую раннюю запись по каждому названию
delete from public.works a
using public.works b
where a.title = b.title
  and a.ctid > b.ctid;

-- 2) Уникальность по названию — чтобы повторный сид больше не плодил дубли.
--    После этого `on conflict do nothing` в схеме реально срабатывает.
alter table public.works
  add constraint works_title_unique unique (title);

-- Проверка: должно остаться 8 работ
-- select position, title, flow_url from public.works order by position;
