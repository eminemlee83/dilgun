-- ══════════════════════════════════════════════════════════
-- 상황보고 관리자 — Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에 그대로 붙여넣고 실행하세요.
-- ══════════════════════════════════════════════════════════

-- 1. 상품 테이블
create table products (
  id          text primary key default ('n' || extract(epoch from now())::bigint || substr(md5(random()::text), 1, 4)),
  name        text not null,
  cat         text not null default '미분류',
  emoji       text default '📦',

  mart        integer,              -- 군마트가
  q           numeric,              -- 군마트 용량
  u           text,                 -- 군마트 단위

  ref         integer,              -- 시중가
  rq          numeric,              -- 시중 용량
  ru          text,                 -- 시중 단위
  ref_date    date,                 -- 시중가 확인일

  hist        jsonb default '[]'::jsonb,  -- 가격 이력 배열

  pick        boolean default false,      -- 추천 여부
  pick_note   text default '',
  hidden      boolean default false,      -- 앱 노출 여부 (false = 노출)
  fav         boolean default false,      -- 단골 여부
  promo_ends  date,                       -- 행사 종료일
  memo        text default '',

  added       date default current_date,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- 2. 변경 로그 테이블 (admin.html의 LOG 배열 대응)
create table product_logs (
  id          bigint generated always as identity primary key,
  message     text not null,
  created_at  timestamptz default now()
);

-- 3. updated_at 자동 갱신 트리거
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_products_updated_at
before update on products
for each row execute function set_updated_at();

-- 4. RLS(Row Level Security) 활성화
alter table products enable row level security;
alter table product_logs enable row level security;

-- 5. 정책: 누구나 "노출된" 상품은 읽을 수 있음 (소비자 앱용)
create policy "public_read_visible_products"
on products for select
using (hidden = false);

-- 6. 정책: 인증된 사용자(관리자)는 전체 읽기/쓰기 가능
--    admin.html 은 Supabase Auth 로그인 후 이 role 을 사용
create policy "admin_full_access_products"
on products for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "admin_full_access_logs"
on product_logs for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

-- 참고: 관리자 계정이 1명뿐이라면 auth.role() 체크 대신
-- auth.uid() = '본인_UUID' 로 더 좁혀도 됩니다.

-- 7. 인덱스 (목록 정렬/필터 자주 쓰는 컬럼)
create index idx_products_hidden on products(hidden);
create index idx_products_pick on products(pick);
create index idx_products_ref_date on products(ref_date);
