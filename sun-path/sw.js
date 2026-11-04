// Sun Path — offline support: network first (so updates arrive at once), cached copy when offline.
const CACHE = "sunpath-v2";
const FILES = ["./", "index.html", "app.js", "astro.js", "manifest.webmanifest", "icon-180.png", "icon-192.png", "icon-512.png"];
self.addEventListener("install", e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES))); self.skipWaiting(); });
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k.startsWith("sunpath-") && k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== location.origin) return;
  e.respondWith(caches.open(CACHE).then(c =>
    fetch(req).then(res => { if (res.ok) c.put(req, res.clone()); return res; })
      .catch(() => c.match(req, { ignoreSearch: true }).then(r => r || c.match("./")))));
});
