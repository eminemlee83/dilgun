/* 딜군 서비스워커
   가격 정보는 항상 최신이어야 하므로 절대 캐시하지 않습니다.
   아이콘·매니페스트 같은 안 바뀌는 파일만 캐시해서, 설치된 앱이
   빨리 뜨고 오프라인에서도 화면 틀은 보이게 합니다. */

const CACHE = "dilgun-shell-v1";
const SHELL = [
  "icon.svg", "favicon.ico", "manifest.json",
  "icon-192.png", "icon-512.png", "apple-touch-icon.png",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);

  /* 데이터·API·HTML 문서는 항상 네트워크로 — 절대 캐시하지 않습니다 */
  const isShellAsset = SHELL.some((f) => url.pathname.endsWith("/" + f));
  if (!isShellAsset || e.request.method !== "GET") return;

  e.respondWith(
    caches.match(e.request).then((cached) =>
      cached ||
      fetch(e.request).then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(e.request, copy));
        return res;
      })
    )
  );
});
