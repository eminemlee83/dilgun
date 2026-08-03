-- ═══ 딜군 : 추천수 · 가격 이력 ═══════════════════════════
-- Supabase SQL Editor에 그대로 붙여넣고 RUN 하세요.

-- 1) 추천수 칸
alter table products add column if not exists likes integer not null default 0;

-- 2) 추천 누르기 — 동시에 여러 명이 눌러도 숫자가 안 어긋나게
--    직접 update 하면 값이 덮어써질 수 있어 함수로 처리합니다.
create or replace function bump_like(pid text)
returns integer
language plpgsql
security definer
as $$
declare n integer;
begin
  update products set likes = likes + 1 where id = pid returning likes into n;
  return coalesce(n, 0);
end;
$$;

grant execute on function bump_like(text) to anon, authenticated;

-- 3) 가격 이력 칸 (이미 있으면 넘어갑니다)
alter table products add column if not exists hist jsonb default '[]'::jsonb;

-- 4) 지금 등록된 상품들에 첫 이력 한 점을 넣어줍니다.
--    형식: [{"d":"2026-08-03","m":2570,"r":8600}]  d=날짜 m=PX가 r=시중가
update products
set hist = jsonb_build_array(
      jsonb_build_object(
        'd', coalesce(ref_date, current_date)::text,
        'm', mart,
        'r', ref))
where ref is not null
  and (hist is null or jsonb_array_length(hist) = 0);

-- 5) 가격이 바뀔 때 이력을 자동으로 쌓습니다.
create or replace function push_price_hist()
returns trigger language plpgsql as $$
begin
  if (new.mart is distinct from old.mart) or (new.ref is distinct from old.ref) then
    new.hist = coalesce(old.hist, '[]'::jsonb) || jsonb_build_object(
      'd', coalesce(new.ref_date, current_date)::text,
      'm', new.mart,
      'r', new.ref);
    -- 최근 24개만 남깁니다
    if jsonb_array_length(new.hist) > 24 then
      new.hist = (select jsonb_agg(v)
                  from (select v from jsonb_array_elements(new.hist) v
                        offset jsonb_array_length(new.hist) - 24) t);
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_price_hist on products;
create trigger trg_price_hist
before update on products
for each row execute function push_price_hist();
