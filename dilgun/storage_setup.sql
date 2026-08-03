-- 제품 사진을 저장할 공간(버킷)을 만듭니다. 공개로 설정해 viewer.html에서 바로 보이게 합니다.
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

-- 아무나 읽을 수 있게 (공개 사진이므로)
create policy "public read product images"
on storage.objects for select
using (bucket_id = 'product-images');

-- 누구나 올릴 수 있게 (관리자 화면 전용이라 anon key로 접근하므로 임시 전체 허용)
create policy "public upload product images"
on storage.objects for insert
with check (bucket_id = 'product-images');
