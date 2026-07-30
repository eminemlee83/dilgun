# 딜군 — 브랜드 · 배포 안내

## 심볼

**베레모에 가격표가 매달린 형태**입니다. 두 요소가 대등합니다.

베레모는 군용품 중 유일하게 물렁한 물건이라 골랐습니다. 거기에 소매점에서
물건에 매다는 가격표를 그대로 걸었습니다. 베레모가 상품이 되고, 태그에 ₩가
찍혀 값이 붙습니다. 군용품이라는 신호와 가격을 따진다는 신호가 한 동작에
같이 들어갑니다.

태그는 실루엣 밖으로 나오기 때문에 크게 쓸 수 있고, 어두운 테두리가 있어
크라운 위에 얹힌 별개 물건으로 읽힙니다.

### 축소 규칙
| 크기 | 가격표 | ₩ | 구멍 | 음영 |
|---|---|---|---|---|
| 128px 이상 | 표시 | 표시 | 표시 | 표시 |
| 48–127px | 표시 | **생략** | 표시 | **생략** |
| 32px 이하 | 표시 | **생략** | **생략** | **생략** |

₩는 그 크기에서 뭉개져 오히려 태그 모양을 흐립니다. 태그 자체는 절대 빼지
마세요. 가격 앱이라는 유일한 신호입니다.

### 최소 크기
16px. 그 아래로는 쓰지 마세요.

### 여백
심볼 높이의 **1/4** 이상을 사방에 비워두세요.

---

## 팔레트

| 이름 | 값 | 쓰는 곳 |
|---|---|---|
| 올리브 | `#4E6144` | 기본 색. 버튼, 강조 텍스트 |
| 딥 올리브 | `#2E3B28` | 상단 바, 가장 어두운 면 |
| 밴드 | `#33422C` | 심볼 밴드 전용 |
| 음영 | `#42543A` | 심볼 드레이프 전용 |
| 황동 | `#D2A55C` | 가격표 면, ⭐추천 배지 |
| 황동 테두리 | `#A67C3A` | 가격표 테두리 전용 |
| 모래 | `#EDE1C7` | 아이콘 바탕, 스플래시 |
| 워시 | `#F7F4EC` | 화면 배경 |
| 괘선 | `#E2DCCF` | 카드 테두리, 구분선 |

### 판정 신호색
브랜드 올리브와 헷갈리면 안 되므로 채도를 따로 잡았습니다.

| 판정 | 글자 | 배경 |
|---|---|---|
| 이득 | `#2F7D4F` | `#E7F3EA` |
| 주의 | `#B4432A` | `#FBEEE8` |
| 비슷 | `#8A6A20` | `#FBF2DC` |

---

## 파일

### 아이콘
```
icon.svg                   확대해도 안 깨짐. 가능하면 이걸 우선
icon-192.png               PWA 기본
icon-512.png               PWA 기본
icon-192-maskable.png      안드로이드 적응형 (여백 넉넉)
icon-512-maskable.png      안드로이드 적응형
apple-touch-icon.png       iOS 홈 화면 (180)
favicon.ico                16·32·48·64 다중 해상도
favicon-16.png / -32.png
favicon.svg                모표·음영 뺀 축소용
```

### 스플래시
```
splash-1170x2532-iphone.png       아이폰 13·14·15
splash-1284x2778-iphone-max.png   프로 맥스
splash-828x1792-iphone-xr.png     XR·11
splash-1536x2048-ipad.png         아이패드
```

### 원본
```
logo-mark.png       심볼 1024px (투명 배경)
logo-wordmark.png   딜군 글자 1024px (투명 배경)
logo-sheet.svg      전체 조합 시트
```

---

## 붙이는 법

### 1. 파일을 전부 같은 폴더에 두세요
HTML 4개와 아이콘·매니페스트가 같은 위치에 있어야 링크가 맞습니다.

### 2. head 태그는 이미 들어가 있습니다
4개 HTML 상단에 아래가 삽입돼 있습니다. 손대실 필요 없습니다.

```html
<link rel="icon" href="favicon.ico" sizes="any">
<link rel="icon" type="image/svg+xml" href="icon.svg">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#EDE1C7">
```

### 3. iOS 스플래시는 따로 넣어야 합니다
아이폰에서 홈 화면에 추가했을 때 시작 화면을 쓰려면,
`viewer.html`의 head에 기기별로 한 줄씩 추가하세요.

```html
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">

<link rel="apple-touch-startup-image" href="splash-1170x2532-iphone.png"
      media="(device-width:390px) and (device-height:844px) and (-webkit-device-pixel-ratio:3)">
<link rel="apple-touch-startup-image" href="splash-1284x2778-iphone-max.png"
      media="(device-width:428px) and (device-height:926px) and (-webkit-device-pixel-ratio:3)">
<link rel="apple-touch-startup-image" href="splash-828x1792-iphone-xr.png"
      media="(device-width:414px) and (device-height:896px) and (-webkit-device-pixel-ratio:2)">
<link rel="apple-touch-startup-image" href="splash-1536x2048-ipad.png"
      media="(device-width:768px) and (device-height:1024px) and (-webkit-device-pixel-ratio:2)">
```

안드로이드는 매니페스트의 `background_color`와 아이콘으로 자동 생성되므로
따로 안 하셔도 됩니다.

### 4. 남은 설정
`SETUP_GUIDE.md`대로 Supabase 키를 넣으시면 됩니다.
키는 HTML 4개 모두 상단에 자리가 있습니다.

---

## 이름

한글 **딜군**, 로마자 **dilgun**.

`dealgun`은 쓰지 마세요. 인도에 있던 할인쿠폰 앱이 쓰던 철자라
도메인과 플레이스토어에 흔적이 남아 있고, 하필 컨셉까지 겹칩니다.

키프리스 상표 검색은 국내·해외 모두 0건으로 확인했습니다(9류·35류).
실제 출원하실 거면 변리사 상담을 한 번 받아보세요.
