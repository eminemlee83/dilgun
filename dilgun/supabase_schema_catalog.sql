-- ══════════════════════════════════════════════════════════
-- 상품 자동등록 — catalog_items 테이블
-- 기존 supabase_schema.sql (products, product_logs)과는 별개입니다.
-- 같은 Supabase 프로젝트의 SQL Editor에 그대로 실행하세요.
-- ══════════════════════════════════════════════════════════

create table catalog_items (
  id          text primary key default ('c' || extract(epoch from now())::bigint || substr(md5(random()::text), 1, 4)),
  name        text not null,
  brand       text default '',
  price       integer not null,
  category    text not null default '기타',
  memo        text default '',
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create or replace function set_updated_at_catalog()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_catalog_items_updated_at
before update on catalog_items
for each row execute function set_updated_at_catalog();

alter table catalog_items enable row level security;

-- 임시(로그인 붙이기 전): anon key로 읽기/쓰기 모두 허용
-- ⚠️ 로그인 화면을 붙이면 이 정책을 authenticated 전용으로 좁히세요 (products 테이블과 동일 패턴)
create policy "temp_open_access_catalog"
on catalog_items for all
using (true)
with check (true);

create index idx_catalog_category on catalog_items(category);
