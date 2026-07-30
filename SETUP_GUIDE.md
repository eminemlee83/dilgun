# 상황보고 관리자 — Supabase 연동 설정 가이드

## 1. Supabase 프로젝트 생성
1. https://supabase.com 접속 → 새 프로젝트 생성
2. 프로젝트 생성 후 **Settings > API** 에서 두 값 확인
   - `Project URL` (예: `https://abcdefgh.supabase.co`)
   - `anon public` 키

## 2. 데이터베이스 스키마 적용
1. Supabase 대시보드 좌측 메뉴 **SQL Editor** 클릭
2. `supabase_schema.sql` 파일 내용 전체를 붙여넣고 **Run**
3. 좌측 **Table Editor**에서 `products`, `product_logs` 테이블이 생겼는지 확인

## 3. 기존 상품 데이터 이전
지금 admin.html에 하드코딩되어 있던 상품 10개를 그대로 옮기고 싶다면,
Table Editor에서 `products` 테이블에 직접 행을 추가하거나,
아래처럼 SQL로 한 번에 넣을 수 있습니다 (예시 1건):

```sql
insert into products (name, cat, mart, q, u, ref, rq, ru, ref_date, hist, emoji, pick, pick_note, hidden, fav, added, promo_ends, memo)
values ('비타500 100ml 10개입', '음료', 4500, 10, '개', 5980, 10, '개', '2026-07-24',
        '[4300,4500]', '🥤', true, '시중 대비 차이가 가장 큽니다', false, true, '2026-07-15', null, '');
```

## 4. 코드에 키 입력
두 파일 모두 상단에 아래 부분이 있습니다. 값으로 교체해주세요.

- `admin_supabase.html`
- `viewer.html`

```js
const SUPABASE_URL = "https://YOUR-PROJECT-ID.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
```

### 추가: Claude Vision API 키 (스크린샷 인식용)
admin_supabase.html에만 필요합니다. 상단에서:

```js
const ANTHROPIC_API_KEY = "sk-ant-YOUR-API-KEY";
```

[Anthropic Console](https://console.anthropic.com)에서 API 키 발급하세요.
- 무료 체험: $5 크레딧 제공
- 실비용: 이미지당 약 5~10원 (와몰 스크린샷 1장에 몇 초 정도의 비용)

## 5. 관리자 접근 제어 (중요)
지금 SQL의 정책은 `auth.role() = 'authenticated'`, 즉 **로그인한 사용자**에게 전체 권한을 줍니다.
admin_supabase.html에는 아직 로그인 화면이 없으므로, 다음 중 하나를 선택하세요.

- **간단히**: Supabase Auth로 이메일/비밀번호 로그인 화면을 admin_supabase.html 앞에 붙인다
- **더 간단히(임시)**: admin 페이지를 Vercel의 비밀번호 보호 기능이나 Basic Auth로 감싸고,
  RLS 정책은 anon key도 쓸 수 있게 완화한다 (내부용으로만 쓸 경우)

지금 상태로 배포하면 anon key와 URL만 알아도 데이터 수정이 가능하니,
**로그인 화면 없이는 인터넷에 공개 배포하지 마세요.**

## 6. 배포
- `viewer.html` → 소비자용, 누구나 접근 가능 (Vercel에 그냥 올리면 됨)
- `admin_supabase.html` → 관리자 전용, 로그인 붙인 뒤 별도 경로(`/admin`)로 배포
  또는 당분간은 본인만 아는 URL로 두고 5번의 완화된 정책 사용

## 7. 로컬 테스트
브라우저에서 파일을 직접 열면 CORS 문제없이 잘 동작합니다 (Supabase는 CDN 방식이라
로컬 서버 없이도 테스트 가능). 다만 최종 배포는 Vercel 등 정적 호스팅에 올리는 걸 권장합니다.

---

### 변경된 부분 요약 (admin.html → admin_supabase.html)
| 항목 | 이전 | 이후 |
|---|---|---|
| 상품 데이터 | 하드코딩된 배열 | `products` 테이블에서 `loadDB()`로 불러옴 |
| 변경 로그 | 메모리에만 저장 | `product_logs` 테이블에 저장, 새로고침해도 유지 |
| 가격 반영 (`applyDiff`) | 배열만 수정 | Supabase `update`/`insert` 후 배열 갱신 |
| 시중가 저장 (`saveRef`) | 배열만 수정 | Supabase `update` |
| 상품 편집 (`saveEdit`) | 배열만 수정 | Supabase `update` |
| 입력 방식 | 텍스트만 | **+ Claude Vision API로 이미지에서 자동 인식** |
