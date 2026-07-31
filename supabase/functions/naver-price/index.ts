// 딜군 — 네이버쇼핑 시세 조회
//
// 브라우저는 네이버 API를 직접 못 부릅니다(CORS). 그래서 이 함수가 대신 물어보고
// 필요한 것만 추려 돌려줍니다. 네이버 키는 이 서버에만 있고 브라우저로 나가지 않습니다.
//
// 배포:
//   supabase functions deploy naver-price
//   supabase secrets set NAVER_CLIENT_ID=xxx NAVER_CLIENT_SECRET=yyy

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json; charset=utf-8" },
  });

/** 네이버가 검색어를 <b>로 감싸 보내므로 태그를 걷어냅니다. */
const stripTags = (s: string) =>
  String(s ?? "")
    .replace(/<[^>]*>/g, "")
    .replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"').replace(/&#39;/g, "'")
    .trim();

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "POST로 불러주세요" }, 405);

  const id = Deno.env.get("NAVER_CLIENT_ID");
  const secret = Deno.env.get("NAVER_CLIENT_SECRET");
  if (!id || !secret) {
    return json({ error: "네이버 키가 설정되지 않았습니다. secrets를 확인해 주세요." }, 500);
  }

  let query = "", display = 10;
  try {
    const body = await req.json();
    query = String(body.query ?? "").trim();
    display = Math.min(Math.max(Number(body.display) || 10, 1), 20);
  } catch {
    return json({ error: "요청 형식을 읽지 못했습니다" }, 400);
  }
  if (!query) return json({ error: "검색어가 비었습니다" }, 400);

  const url = new URL("https://openapi.naver.com/v1/search/shop.json");
  url.searchParams.set("query", query);
  url.searchParams.set("display", String(display));
  url.searchParams.set("sort", "sim"); // 정확도순. 최저가순은 엉뚱한 부속품이 올라옵니다.

  let res: Response;
  try {
    res = await fetch(url, {
      headers: { "X-Naver-Client-Id": id, "X-Naver-Client-Secret": secret },
    });
  } catch (e) {
    return json({ error: "네이버에 연결하지 못했습니다", detail: String(e) }, 502);
  }

  if (!res.ok) {
    const detail = (await res.text()).slice(0, 300);
    return json({ error: `네이버가 ${res.status}로 답했습니다`, detail }, 502);
  }

  const data = await res.json();

  const items = (data.items ?? [])
    .map((it: Record<string, string>) => ({
      title: stripTags(it.title),
      price: Number(it.lprice) || null,
      image: it.image || null,
      mall: it.mallName || "",
      brand: it.brand || it.maker || "",
      category: it.category2 || it.category1 || "",
      link: it.link || "",
    }))
    .filter((x: { price: number | null }) => x.price);

  /* 최저가 하나만 믿기 어려우니 중앙값도 같이 보냅니다.
     터무니없이 싼 미끼 상품에 휘둘리지 않도록. */
  const prices = items.map((x: { price: number }) => x.price).sort((a: number, b: number) => a - b);
  const median = prices.length
    ? prices.length % 2
      ? prices[(prices.length - 1) / 2]
      : Math.round((prices[prices.length / 2 - 1] + prices[prices.length / 2]) / 2)
    : null;

  return json({
    query,
    total: data.total ?? 0,
    lowest: prices[0] ?? null,
    median,
    items,
  });
});
