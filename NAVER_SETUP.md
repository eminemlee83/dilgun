# 네이버쇼핑 연동 설치

시중가와 제품 사진을 손으로 찾아 넣는 대신, 상품명으로 검색해
결과를 한 번 누르면 둘 다 채워지게 만드는 작업입니다.

브라우저는 네이버 API를 직접 못 부릅니다(CORS). 그래서 Supabase에
중계 함수를 하나 두고, 네이버 키는 그 서버에만 둡니다. 키가 브라우저로
새어 나가지 않는 구조입니다.

전부 합쳐 **20분** 정도 걸립니다.

---

## 1. 네이버 키 발급 (7분)

1. https://developers.naver.com/apps/#/register 접속 · 네이버 로그인
2. **애플리케이션 이름**: `딜군`
3. **사용 API**: `검색` 선택
4. **비로그인 오픈 API 서비스 환경**: `WEB 설정` 추가
   - 웹 서비스 URL: `https://dilgun.vercel.app`
5. 등록하면 **Client ID**와 **Client Secret**이 나옵니다. 둘 다 복사해 두세요.

무료 사용량은 하루 25,000건입니다. 상품 543개를 여러 번 검색해도 남습니다.

---

## 2. Supabase CLI 설치 (5분)

Edge Function은 CLI로 올려야 합니다.

**Windows (PowerShell)**
```powershell
scoop install supabase
```
scoop이 없다면: https://github.com/supabase/cli/releases 에서
`supabase_windows_amd64.zip`을 받아 압축을 풀고 그 폴더에서 명령을 실행하세요.

**macOS**
```bash
brew install supabase/tap/supabase
```

설치 확인:
```bash
supabase --version
```

---

## 3. 함수 올리기 (5분)

`dilgun` 폴더에서 순서대로 실행합니다.

```bash
# 1) 로그인 — 브라우저가 열립니다
supabase login

# 2) 내 프로젝트와 연결
supabase link --project-ref zxbiwyjlnkiygibxxsof

# 3) 네이버 키를 서버에 저장 (따옴표 없이 값만)
supabase secrets set NAVER_CLIENT_ID=발급받은아이디
supabase secrets set NAVER_CLIENT_SECRET=발급받은시크릿

# 4) 함수 배포
supabase functions deploy naver-price
```

`Deployed Function naver-price` 가 나오면 끝입니다.

프로젝트 ref는 Supabase 대시보드 **Settings → General → Project ID**에 있습니다.

---

## 4. 사진 칸 만들기 (1분)

Supabase **SQL Editor**에서 실행하세요.

```sql
alter table products add column if not exists img text;
```

---

## 5. 확인

```
https://dilgun.vercel.app/price_entry.html
```

상품 카드가 뜨면서 아래에 네이버 결과가 자동으로 나와야 합니다.
결과를 하나 누르면 **시중가와 사진 주소가 함께** 채워집니다.

---

## 잘 안 될 때

**"네이버 키가 설정되지 않았습니다"**
→ 3번의 secrets 단계를 다시 실행하고, 함수를 다시 배포하세요.
   secrets를 바꾼 뒤에는 배포를 한 번 더 해야 반영됩니다.

**"네이버가 401로 답했습니다"**
→ Client ID나 Secret이 틀렸습니다. 앞뒤 공백이 붙지 않았는지 확인하세요.

**"결과가 없습니다"**
→ 상품명이 PX 전용 표기라 검색이 안 되는 경우입니다.
   검색어 칸에서 짧게 줄여 다시 찾으세요. 예: `우아한 직화구이 오징어` → `직화 오징어`

**함수는 떴는데 화면에서 조회가 안 될 때**
→ `price_entry.html` 상단의 `SUPABASE_URL`과 `SUPABASE_ANON_KEY`가
   비어 있는지 확인하세요. 주소 끝에 `/rest/v1/`을 붙이면 안 됩니다.

---

## 검색어를 줄이면 잘 찾습니다

PX 상품명에는 `(영외)`, `(펫)`, `(동계)` 같은 꼬리표가 붙습니다.
괄호 안은 자동으로 걷어내지만, 그래도 안 나오면 브랜드와 핵심 단어만 남기세요.

| 원래 이름 | 검색어 |
|---|---|
| (영외)청정원 현미식초 (900ml) | 청정원 현미식초 |
| 라온쿡 푸짐한 도시락 | 라온쿡 도시락 |
| 우아한 직화구이 오징어 | 직화 오징어 |

---

## 판정 기준은 최저가입니다

카드 위에 `최저 · 중앙`이 같이 뜹니다.
최저가 하나만 보면 미끼 상품에 휘둘리기 쉬우니, 중앙값과 크게 벌어져 있으면
목록을 눈으로 한 번 훑고 고르세요.
