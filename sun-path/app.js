/* Sun Path — camera overlay, sensors, UI. */
(function () {
  "use strict";
  const $ = id => document.getElementById(id);
  const D2R = Math.PI / 180, R2D = 180 / Math.PI;
  const norm360 = x => { x %= 360; return x < 0 ? x + 360 : x; };
  const wrap180 = x => { x = norm360(x); return x > 180 ? x - 360 : x; };
  const clamp = (x, a, b) => Math.max(a, Math.min(b, x));

  // ---------------------------------------------------------------- i18n
  const STR = {
    en: {
      appName: "Sun Path", tagline: "See where the sun travels across your sky — today, on any date, and during eclipses.",
      start: "Start", startNote: "Uses the camera, motion sensors and location. Nothing leaves your device.",
      calibrate: "Calibrate", travel: "Time Travel", compare: "Compare Dates", solstice: "Solstice Arcs",
      eclipses: "Upcoming Eclipses", language: "Language", cancel: "Cancel", done: "Done", now: "Now", reset: "Reset",
      sun: "Sun", timeTravel: "Time travel", calibrating: "Calibrating", gyroOnly: "Gyro only — magnetic interference",
      noCompass: "No compass — align with Calibrate", manual: "Drag to look around",
      about: "About Sun Path",
      howTitle: "How it works", how: "The yellow line is the sun's path for the day. The solid part is above the horizon, the dashed part below it. Dots mark each hour; arrows mark sunrise and sunset.",
      offlineTitle: "Works offline", offline: "All calculations run on your phone. Sun position (VSOP87), moon position (ELP-2000/82) and eclipse contacts are computed locally — after the first visit no internet connection is needed.",
      sensorsTitle: "Sensors", sensors: "The gyroscope and accelerometer track how you hold the phone; the compass only keeps that alignment pointed at true north. When compass readings jump or become unreliable — near metal, cars or speakers — the app holds the last good alignment and continues on the gyroscope alone.",
      accTitle: "Accuracy", acc: "The sun's position is accurate to about 1 arcsecond, eclipse contact times to within about 30 seconds. How well the overlay matches the real sky depends mostly on your phone's compass — use Calibrate → Align to sun for the best result.",
      status: "Status", location: "Location", compass: "Compass", noonAlt: "Noon altitude", declination: "Magnetic declination", today: "Today",
      sunrise: "Sunrise", sunset: "Sunset", noon: "Solar noon", daylength: "Day length", polarDay: "Sun never sets", polarNight: "Sun never rises",
      edit: "Edit", save: "Save", useGps: "Use GPS", lat: "Latitude", lon: "Longitude",
      gps: "GPS", manualLoc: "set manually", approxLoc: "approximate — tap Edit",
      cmpGood: "good (compass + gyro)", cmpGyro: "gyro only (interference)", cmpNone: "not available", cmpManual: "no motion sensors",
      calHelp: "Tap the real sun on the screen, or aim the crosshair at it and tap Align to sun. Drag to nudge.",
      calHelpNight: "The sun is below the horizon. Drag the screen to nudge the overlay onto a known direction.",
      alignSun: "Align to sun", fov: "Field of view", offset: "Offset", figure8: "If directions look wrong, wave the phone in a figure-8 to recalibrate its compass.",
      aligned: "Aligned to the sun", autoAligned: "☀ Sun found in the camera — overlay aligned", autoAlign: "Auto-align when the sun is in view", waitLoc: "Waiting for location…", calibration: "Calibration",
      cmpTitle: "Compare with", hideCmp: "Turn off",
      junSol: "June solstice", decSol: "December solstice", marEq: "March equinox", plus1m: "+1 month", plus6m: "+6 months",
      solOn: "Solstice arcs on", solOff: "Solstice arcs off", equinox: "Equinox",
      eclTitle: "Upcoming Eclipses", eclIntro: "Solar eclipses visible from your location, with local times.",
      calcing: "Calculating…", noEcl: "No solar eclipses visible from here in the next 30 years.",
      total: "Total solar eclipse", annular: "Annular solar eclipse", partial: "Partial solar eclipse",
      hereTotal: "Total here", hereAnnular: "Annular here", herePartial: "Partial here",
      obsc: "covered", sunAlt: "sun at", risesE: "sun rises eclipsed", setsE: "sun sets eclipsed",
      showSky: "Show in sky", begins: "Begins", max: "Max", ends: "Ends", eclipse: "Eclipse",
      noCam: "Camera unavailable — showing the sky without video", noLoc: "Location unavailable — set it in About",
      noSensors: "No motion sensors — drag to look around", saved: "Photo saved", photo: "Photo",
      tapToStart: "Tap to enable motion sensors",
      dirs: ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"],
      locale: "en-GB"
    },
    lt: {
      appName: "Saulės kelias", tagline: "Pamatyk, kur saulė keliauja tavo danguje — šiandien, bet kurią dieną ir užtemimų metu.",
      start: "Pradėti", startNote: "Naudoja kamerą, judesio jutiklius ir vietą. Niekas neišsiunčiama iš telefono.",
      calibrate: "Kalibruoti", travel: "Kelionė laiku", compare: "Palyginti datas", solstice: "Saulėgrįžų lankai",
      eclipses: "Artimiausi užtemimai", language: "Kalba", cancel: "Atšaukti", done: "Baigti", now: "Dabar", reset: "Atstatyti",
      sun: "Saulė", timeTravel: "Kelionė laiku", calibrating: "Kalibruojama", gyroOnly: "Tik giroskopas — magnetiniai trikdžiai",
      noCompass: "Nėra kompaso — sulygink per Kalibruoti", manual: "Tempk, kad apsidairytum",
      about: "Apie Saulės kelią",
      howTitle: "Kaip tai veikia", how: "Geltona linija — saulės kelias per dieną. Ištisinė dalis yra virš horizonto, punktyrinė — po juo. Taškai žymi valandas, rodyklės — saulėtekį ir saulėlydį.",
      offlineTitle: "Veikia be interneto", offline: "Visi skaičiavimai atliekami telefone. Saulės padėtis (VSOP87), Mėnulio padėtis (ELP-2000/82) ir užtemimų kontaktai skaičiuojami vietoje — po pirmo apsilankymo internetas nebereikalingas.",
      sensorsTitle: "Jutikliai", sensors: "Giroskopas ir akselerometras seka, kaip laikai telefoną, o kompasas tik palaiko kryptį į tikrąją šiaurę. Kai kompaso rodmenys šokinėja ar tampa nepatikimi — prie metalo, automobilių ar garsiakalbių — programa išlaiko paskutinę gerą kryptį ir toliau naudoja tik giroskopą.",
      accTitle: "Tikslumas", acc: "Saulės padėtis tiksli maždaug iki 1 lanko sekundės, užtemimų kontaktų laikai — iki ~30 sekundžių. Kaip tiksliai piešinys sutampa su dangumi, labiausiai priklauso nuo telefono kompaso — geriausiam rezultatui naudok Kalibruoti → Sulygiuoti su saule.",
      status: "Būsena", location: "Vieta", compass: "Kompasas", noonAlt: "Aukštis vidurdienį", declination: "Magnetinė deklinacija", today: "Šiandien",
      sunrise: "Saulėtekis", sunset: "Saulėlydis", noon: "Saulės vidurdienis", daylength: "Dienos ilgumas", polarDay: "Saulė nenusileidžia", polarNight: "Saulė nepateka",
      edit: "Keisti", save: "Išsaugoti", useGps: "Naudoti GPS", lat: "Platuma", lon: "Ilguma",
      gps: "GPS", manualLoc: "nustatyta rankiniu būdu", approxLoc: "apytikslė — spausk Keisti",
      cmpGood: "geras (kompasas + giroskopas)", cmpGyro: "tik giroskopas (trikdžiai)", cmpNone: "nėra", cmpManual: "nėra judesio jutiklių",
      calHelp: "Paliesk tikrąją saulę ekrane arba nukreipk į ją kryželį ir spausk „Sulygiuoti su saule“. Tempk, kad pataisytum.",
      calHelpNight: "Saulė po horizontu. Tempk ekraną, kad sulygintum piešinį su žinoma kryptimi.",
      alignSun: "Sulygiuoti su saule", fov: "Matymo kampas", offset: "Pataisa", figure8: "Jei kryptys atrodo neteisingos, pamojuok telefonu aštuoniuke, kad kompasas persikalibruotų.",
      aligned: "Sulygiuota su saule", autoAligned: "☀ Saulė rasta kameroje — piešinys sulygiuotas", autoAlign: "Automatiškai lygiuoti, kai saulė matoma", waitLoc: "Laukiama vietos…", calibration: "Kalibravimas",
      cmpTitle: "Palyginti su", hideCmp: "Išjungti",
      junSol: "Birželio saulėgrįža", decSol: "Gruodžio saulėgrįža", marEq: "Kovo lygiadienis", plus1m: "+1 mėn.", plus6m: "+6 mėn.",
      solOn: "Saulėgrįžų lankai įjungti", solOff: "Saulėgrįžų lankai išjungti", equinox: "Lygiadienis",
      eclTitle: "Artimiausi užtemimai", eclIntro: "Saulės užtemimai, matomi iš tavo vietos, vietos laiku.",
      calcing: "Skaičiuojama…", noEcl: "Per artimiausius 30 metų iš čia matomų Saulės užtemimų nėra.",
      total: "Visiškas Saulės užtemimas", annular: "Žiedinis Saulės užtemimas", partial: "Dalinis Saulės užtemimas",
      hereTotal: "Čia visiškas", hereAnnular: "Čia žiedinis", herePartial: "Čia dalinis",
      obsc: "uždengta", sunAlt: "saulė", risesE: "saulė teka užtemusi", setsE: "saulė leidžiasi užtemusi",
      showSky: "Rodyti danguje", begins: "Pradžia", max: "Maks.", ends: "Pabaiga", eclipse: "Užtemimas",
      noCam: "Kamera nepasiekiama — rodomas dangus be vaizdo", noLoc: "Vieta nežinoma — nustatyk ją skiltyje Apie",
      noSensors: "Nėra judesio jutiklių — tempk, kad apsidairytum", saved: "Nuotrauka išsaugota", photo: "Nuotrauka",
      tapToStart: "Paliesk, kad įjungtum judesio jutiklius",
      dirs: ["Š","ŠŠR","ŠR","RŠR","R","RPR","PR","PPR","P","PPV","PV","VPV","V","VŠV","ŠV","ŠŠV"],
      locale: "lt-LT"
    }
  };

  // ---------------------------------------------------------------- persisted settings
  const store = {
    get(k, d) { try { const v = localStorage.getItem("sunpath." + k); return v === null ? d : JSON.parse(v); } catch (e) { return d; } },
    set(k, v) { try { localStorage.setItem("sunpath." + k, JSON.stringify(v)); } catch (e) { /* private mode */ } }
  };
  const S = {
    lang: store.get("lang", (navigator.language || "en").toLowerCase().startsWith("lt") ? "lt" : "en"),
    loc: store.get("loc", null),
    cal: Object.assign({ yaw: 0, pitch: 0, fov: 64, auto: true }, store.get("cal", {})),
    solstice: store.get("solstice", false),
    travel: null, compare: null, eclipse: null, playing: false,
    panel: null, sheet: null,
    view: { yaw: 150, pitch: 15 }, // manual look-around (no sensors)
    started: false
  };
  const t = k => (STR[S.lang] && STR[S.lang][k]) || STR.en[k] || k;

  if (!S.loc) {
    // rough guess from the time zone until GPS answers
    S.loc = { lat: 50, lon: clamp(-new Date().getTimezoneOffset() / 4, -180, 180), h: 0, src: "approx" };
  }

  function applyI18n() {
    document.documentElement.lang = S.lang;
    document.querySelectorAll("[data-i18n]").forEach(el => { el.textContent = t(el.dataset.i18n); });
    $("startLang").textContent = S.lang === "lt" ? "English" : "Lietuvių";
    document.title = t("appName");
  }

  // ---------------------------------------------------------------- formatting
  const fmtTime = d => d ? new Intl.DateTimeFormat(t("locale"), { hour: "2-digit", minute: "2-digit" }).format(d) : "—";
  const fmtDate = d => new Intl.DateTimeFormat(t("locale"), { weekday: "short", day: "numeric", month: "short", year: "numeric" }).format(d);
  const fmtShortDate = d => new Intl.DateTimeFormat(t("locale"), { day: "numeric", month: "short" }).format(d);
  const fmtLongDate = d => new Intl.DateTimeFormat(t("locale"), { day: "numeric", month: "long", year: "numeric" }).format(d);
  const fmtDur = ms => { const m = Math.round(ms / 60000); return Math.floor(m / 60) + " h " + String(m % 60).padStart(2, "0") + " min"; };
  const fmtDeg = (x, d = 0) => x.toFixed(d) + "°";
  const dirName = az => t("dirs")[Math.round(norm360(az) / 22.5) % 16];
  const dayStart = d => new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const dateInputValue = d => d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
  const parseDateInput = (v, keepTimeFrom) => {
    const [y, m, dd] = v.split("-").map(Number);
    const k = keepTimeFrom || new Date();
    return new Date(y, m - 1, dd, k.getHours(), k.getMinutes());
  };
  const obs = () => ({ lat: S.loc.lat, lon: S.loc.lon, h: S.loc.h || 0 });
  const now = () => S.travel ? new Date(S.travel) : new Date();

  // ---------------------------------------------------------------- sun path cache
  const pathCache = new Map();
  function dayPath(date) {
    const d0 = dayStart(date), d1 = new Date(d0.getFullYear(), d0.getMonth(), d0.getDate() + 1);
    const key = d0.getTime() + "|" + S.loc.lat.toFixed(4) + "|" + S.loc.lon.toFixed(4);
    if (pathCache.has(key)) return pathCache.get(key);
    const pts = [], o = obs();
    for (let tm = d0.getTime(); tm <= d1.getTime(); tm += 120000) {
      const p = Astro.sunPosition(new Date(tm), o);
      pts.push({ t: tm, az: p.az, alt: p.alt });
    }
    const hours = [];
    for (let h = 0; h < 24; h++) {
      const tm = new Date(d0.getFullYear(), d0.getMonth(), d0.getDate(), h).getTime();
      const p = Astro.sunPosition(new Date(tm), o);
      hours.push({ h, az: p.az, alt: p.alt });
    }
    const ev = Astro.sunEvents(d0, o);
    const rs = [ev.rise, ev.set].map(x => x && Object.assign({ t: x, kind: x === ev.rise ? "rise" : "set" }, Astro.sunPosition(x, o)));
    let apex = pts[0];
    for (const p of pts) if (p.alt > apex.alt) apex = p;
    const res = { pts, hours, ev, rs: rs.filter(Boolean), apex, date: d0 };
    if (pathCache.size > 24) pathCache.clear();
    pathCache.set(key, res);
    return res;
  }

  // ---------------------------------------------------------------- matrices
  const Rz = a => { const c = Math.cos(a * D2R), s = Math.sin(a * D2R); return [c, -s, 0, s, c, 0, 0, 0, 1]; };
  const Rx = a => { const c = Math.cos(a * D2R), s = Math.sin(a * D2R); return [1, 0, 0, 0, c, -s, 0, s, c]; };
  const Ry = a => { const c = Math.cos(a * D2R), s = Math.sin(a * D2R); return [c, 0, s, 0, 1, 0, -s, 0, c]; };
  const mul = (A, B) => {
    const r = new Array(9);
    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) r[i * 3 + j] = A[i * 3] * B[j] + A[i * 3 + 1] * B[3 + j] + A[i * 3 + 2] * B[6 + j];
    return r;
  };
  const apply = (R, v) => [R[0] * v[0] + R[1] * v[1] + R[2] * v[2], R[3] * v[0] + R[4] * v[1] + R[5] * v[2], R[6] * v[0] + R[7] * v[1] + R[8] * v[2]];
  const applyT = (R, v) => [R[0] * v[0] + R[3] * v[1] + R[6] * v[2], R[1] * v[0] + R[4] * v[1] + R[7] * v[2], R[2] * v[0] + R[5] * v[1] + R[8] * v[2]];
  const euler = (a, b, g) => mul(mul(Rz(a), Rx(b)), Ry(g)); // W3C DeviceOrientation: world ← device
  const headingOf = w => norm360(Math.atan2(w[0], w[1]) * R2D);   // world x = east, y = north
  function quatFrom(R) {
    const tr = R[0] + R[4] + R[8]; let w, x, y, z;
    if (tr > 0) { const s = Math.sqrt(tr + 1) * 2; w = s / 4; x = (R[7] - R[5]) / s; y = (R[2] - R[6]) / s; z = (R[3] - R[1]) / s; }
    else if (R[0] > R[4] && R[0] > R[8]) { const s = Math.sqrt(1 + R[0] - R[4] - R[8]) * 2; w = (R[7] - R[5]) / s; x = s / 4; y = (R[1] + R[3]) / s; z = (R[2] + R[6]) / s; }
    else if (R[4] > R[8]) { const s = Math.sqrt(1 + R[4] - R[0] - R[8]) * 2; w = (R[2] - R[6]) / s; x = (R[1] + R[3]) / s; y = s / 4; z = (R[5] + R[7]) / s; }
    else { const s = Math.sqrt(1 + R[8] - R[0] - R[4]) * 2; w = (R[3] - R[1]) / s; x = (R[2] + R[6]) / s; y = (R[5] + R[7]) / s; z = s / 4; }
    return [w, x, y, z];
  }
  function matFrom(q) {
    const [w, x, y, z] = q;
    return [1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w),
            2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w),
            2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)];
  }
  function nlerp(a, b, k) {
    const dot = a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3], sgn = dot < 0 ? -1 : 1;
    const r = a.map((v, i) => v + (sgn * b[i] - v) * k), n = Math.hypot(...r);
    return r.map(v => v / n);
  }
  const worldVec = (az, alt) => [Math.cos(alt * D2R) * Math.sin(az * D2R), Math.cos(alt * D2R) * Math.cos(az * D2R), Math.sin(alt * D2R)];

  // ---------------------------------------------------------------- orientation (hybrid compass + gyro)
  const O = {
    events: 0, Rdev: null, Rabs: null, offset: null, mode: "none", acc: null, disagreeSince: 0, lastAbs: 0,
    q: null, decl: 0
  };
  function screenAngle() {
    const a = (screen.orientation && typeof screen.orientation.angle === "number") ? screen.orientation.angle : (window.orientation || 0);
    return a;
  }
  // Heading of the phone used to compare gyro and compass: the top edge when flat, the back camera when upright.
  function refHeading(R) {
    const top = apply(R, [0, 1, 0]);
    if (Math.hypot(top[0], top[1]) > 0.5) return headingOf(top);
    return headingOf(apply(R, [0, 0, -1]));
  }
  function feedCompass(headingTrue, accuracy) {
    if (!O.Rdev) return;
    const tnow = performance.now();
    O.lastAbs = tnow; O.acc = accuracy; O.rawHeading = norm360(headingTrue - O.decl);
    if (accuracy !== null && accuracy < 0) { if (O.offset !== null) O.mode = "gyro"; return; } // iOS: -1 = invalid
    const sample = norm360(headingTrue - refHeading(O.Rdev));
    if (O.offset === null) { O.offset = sample; O.mode = "compass"; O.settleUntil = tnow + 3000; return; }
    const diff = wrap180(sample - O.offset);
    const settling = tnow < O.settleUntil;
    if (!settling && Math.abs(diff) > Math.max(12, (accuracy || 0) * 0.8)) {
      // Compass and gyroscope disagree: ignore brief disagreements (fast turns, nearby metal);
      // if the compass keeps pointing to the same new direction for 5 s, re-anchor to it.
      if (!O.disagreeSince || Math.abs(wrap180(sample - O.cand)) > 8) { O.disagreeSince = tnow; O.cand = sample; }
      else O.cand = norm360(O.cand + wrap180(sample - O.cand) * 0.1);
      const dur = tnow - O.disagreeSince;
      if (dur > 1500) O.mode = "gyro";
      if (dur > 5000) { O.offset = O.cand; O.disagreeSince = 0; O.mode = "compass"; }
      return;
    }
    O.disagreeSince = 0; O.mode = "compass";
    const w = accuracy === null || accuracy <= 15 ? 1 : accuracy <= 30 ? 0.5 : 0.25;
    O.offset = norm360(O.offset + diff * (settling ? 0.15 : 0.02) * w);
  }
  function onOrientation(e) {
    if (e.alpha === null || e.alpha === undefined) return;
    O.events++;
    const R = euler(e.alpha, e.beta, e.gamma);
    if (typeof e.webkitCompassHeading === "number" && !isNaN(e.webkitCompassHeading)) {
      // iOS: alpha is relative to an arbitrary start; webkitCompassHeading is magnetic
      O.Rdev = R;
      feedCompass(norm360(e.webkitCompassHeading + O.decl), typeof e.webkitCompassAccuracy === "number" ? e.webkitCompassAccuracy : null);
    } else if (e.absolute === true) {
      O.Rdev = R; O.absOnly = true;
      feedCompass(norm360(refHeading(R) + O.decl), null);
    } else {
      O.Rdev = R; // relative (gyro) frame; absolute heading comes from deviceorientationabsolute
    }
  }
  function onOrientationAbs(e) {
    if (e.alpha === null || e.alpha === undefined) return;
    const R = euler(e.alpha, e.beta, e.gamma);
    if (!O.Rdev || O.absOnly) { O.Rdev = R; O.events++; }
    feedCompass(norm360(refHeading(R) + O.decl), null);
  }
  function compassState() {
    if (O.manual) return "manual";
    if (O.offset === null || performance.now() - O.lastAbs > 4000) return O.events ? "none" : "manual";
    return O.mode;
  }

  // Camera rotation (world ← screen/camera frame) including calibration.
  function cameraMatrix(raw) {
    if (O.manual || !O.Rdev) return mul(Rz(-S.view.yaw), Rx(90 + S.view.pitch));
    const R = mul(mul(mul(Rz(-((O.offset || 0) + S.cal.yaw)), O.Rdev), Rz(-screenAngle())), Rx(S.cal.pitch));
    if (raw) return R;
    const q = quatFrom(R);
    O.q = O.q ? nlerp(O.q, q, 0.35) : q;
    return matFrom(O.q);
  }

  // ---------------------------------------------------------------- canvas / projection
  const cv = $("overlay"), ctx = cv.getContext("2d"), video = $("cam");
  let W = 0, H = 0, DPR = 1;
  function resize() {
    DPR = Math.min(window.devicePixelRatio || 1, 3);
    W = window.innerWidth; H = window.innerHeight;
    cv.width = Math.round(W * DPR); cv.height = Math.round(H * DPR);
  }
  window.addEventListener("resize", resize);
  resize();

  function focal() {
    let vw = video.videoWidth, vh = video.videoHeight;
    if (!vw || !vh || video.hidden) { if (W < H) { vw = 3; vh = 4; } else { vw = 4; vh = 3; } }
    const scale = Math.max(W / vw, H / vh); // object-fit: cover
    return (Math.max(vw, vh) / 2) / Math.tan(S.cal.fov / 2 * D2R) * scale;
  }
  let CAM = null, F = 1;
  function project(az, alt) {
    const d = applyT(CAM, worldVec(az, alt));
    if (d[2] > -0.05) return null;
    return [W / 2 + F * d[0] / -d[2], H / 2 - F * d[1] / -d[2]];
  }

  function strokePath(points, opts) {
    // points: [{az, alt}] — draws runs above (solid) and below (dashed) the horizon
    const maxJump = Math.max(W, H) * 1.5;
    const drawRun = (run, dashed) => {
      if (run.length < 2) return;
      ctx.beginPath();
      let pen = false, last = null;
      for (const p of run) {
        const s = project(p.az, p.alt);
        if (!s || (last && Math.hypot(s[0] - last[0], s[1] - last[1]) > maxJump)) { pen = false; last = s; continue; }
        if (!pen) { ctx.moveTo(s[0], s[1]); pen = true; } else ctx.lineTo(s[0], s[1]);
        last = s;
      }
      ctx.setLineDash(dashed ? opts.dash || [12, 11] : []);
      ctx.globalAlpha = dashed ? (opts.dashAlpha || 0.8) : 1;
      ctx.stroke();
    };
    ctx.save();
    ctx.strokeStyle = opts.color; ctx.lineWidth = opts.width; ctx.lineCap = "round"; ctx.lineJoin = "round";
    ctx.shadowColor = "rgba(0,0,0,0.35)"; ctx.shadowBlur = 6;
    let run = [], above = null;
    for (const p of points) {
      if (p.alt < (opts.minAlt ?? -40)) { if (run.length) drawRun(run, !above); run = []; above = null; continue; }
      const a = p.alt >= 0;
      if (above === null) above = a;
      if (a !== above) { run.push(p); drawRun(run, !above); run = [p]; above = a; }
      else run.push(p);
    }
    if (run.length) drawRun(run, !above);
    ctx.restore();
  }

  function text(str, x, y, opts) {
    ctx.save();
    ctx.font = (opts.weight || 600) + " " + (opts.size || 14) + "px " + getComputedStyle(document.body).fontFamily;
    ctx.textAlign = opts.align || "center"; ctx.textBaseline = opts.baseline || "middle";
    ctx.shadowColor = "rgba(0,0,0,0.6)"; ctx.shadowBlur = 4;
    ctx.globalAlpha = opts.alpha ?? 1;
    ctx.fillStyle = opts.color || "#fff";
    ctx.fillText(str, x, y);
    ctx.restore();
  }

  function drawHorizon(camAz) {
    const pts = [];
    for (let a = 0; a <= 360; a += 2) pts.push({ az: a, alt: 0 });
    // horizon line
    ctx.save();
    ctx.strokeStyle = "rgba(255,255,255,0.9)"; ctx.lineWidth = 3; ctx.setLineDash([16, 13]);
    ctx.shadowColor = "rgba(0,0,0,0.35)"; ctx.shadowBlur = 4;
    ctx.beginPath();
    let pen = false, last = null;
    for (const p of pts) {
      const s = project(p.az, 0);
      if (!s || (last && Math.abs(s[0] - last[0]) > W * 1.5)) { pen = false; last = s; continue; }
      if (!pen) { ctx.moveTo(s[0], s[1]); pen = true; } else ctx.lineTo(s[0], s[1]);
      last = s;
    }
    ctx.stroke();
    ctx.restore();
    // ticks and compass labels
    for (let a = 0; a < 360; a += 10) {
      const s = project(a, 0);
      if (!s || s[0] < -40 || s[0] > W + 40) continue;
      const major = a % 45 === 0;
      ctx.save();
      ctx.strokeStyle = "rgba(255,255,255," + (major ? 0.9 : 0.45) + ")"; ctx.lineWidth = major ? 2.5 : 1.5;
      ctx.beginPath(); ctx.moveTo(s[0], s[1] + 8); ctx.lineTo(s[0], s[1] + (major ? 40 : 16)); ctx.stroke();
      ctx.restore();
      if (major) text(t("dirs")[a / 22.5], s[0], s[1] - 22, { size: 22, weight: 600, alpha: 0.95 });
      else if (a % 30 === 0) text(String(a), s[0], s[1] + 28, { size: 11, weight: 500, alpha: 0.6 });
    }
    // altitude scale on the left edge
    for (const alt of [-30, -15, 15, 30, 45, 60, 75]) {
      const s = project(camAz, alt);
      if (!s || s[1] < 90 || s[1] > H - 120) continue;
      ctx.save(); ctx.strokeStyle = "rgba(255,255,255,0.75)"; ctx.lineWidth = 2;
      ctx.beginPath(); ctx.moveTo(0, s[1]); ctx.lineTo(44, s[1]); ctx.stroke(); ctx.restore();
      text(alt + "°", 54, s[1], { size: 18, weight: 500, align: "left", alpha: 0.8 });
    }
  }

  function drawGround(camAz, camAlt) {
    const pts = [];
    for (let a = -85; a <= 85; a += 5) { const s = project(camAz + a, 0); if (s) pts.push(s); }
    ctx.save();
    const g = ctx.createLinearGradient(0, 0, 0, H); g.addColorStop(0, "#2A2E35"); g.addColorStop(1, "#121418");
    ctx.fillStyle = g;
    ctx.beginPath();
    if (pts.length < 2) { if (camAlt < 0) ctx.rect(0, 0, W, H); }
    else {
      pts.sort((p, q) => p[0] - q[0]);
      ctx.moveTo(pts[0][0], pts[0][1]);
      for (const p of pts) ctx.lineTo(p[0], p[1]);
      const far = 1e5;
      ctx.lineTo(pts[pts.length - 1][0], far); ctx.lineTo(pts[0][0], far);
    }
    ctx.fill();
    ctx.restore();
  }

  function drawDayPath(dp, color, opts) {
    strokePath(dp.pts, { color, width: opts.width, dashAlpha: opts.dashAlpha, minAlt: -35 });
    if (opts.hours) {
      const proj = dp.hours.map(h => project(h.az, h.alt));
      dp.hours.forEach((h, i) => {
        if (h.alt < -8) return;
        const s = proj[i];
        if (!s) return;
        const nb = proj[i + 1] || proj[i - 1];
        let nx = 0, ny = 1;
        if (nb) { const tx = nb[0] - s[0], ty = nb[1] - s[1], l = Math.hypot(tx, ty) || 1; nx = -ty / l; ny = tx / l; if (ny < 0) { nx = -nx; ny = -ny; } }
        ctx.save(); ctx.fillStyle = color; ctx.strokeStyle = "rgba(0,0,0,0.55)"; ctx.lineWidth = 2;
        ctx.globalAlpha = h.alt < 0 ? 0.7 : 1;
        ctx.beginPath(); ctx.arc(s[0], s[1], opts.width * 0.9 + 1.5, 0, Math.PI * 2); ctx.fill(); ctx.stroke(); ctx.restore();
        text(String(h.h).padStart(2, "0"), s[0] + nx * 19, s[1] + ny * 19, { size: 13, weight: 600, color, alpha: h.alt < 0 ? 0.6 : 0.95 });
      });
    }
    if (opts.events) {
      for (const r of dp.rs) {
        const s = project(r.az, 0);
        if (!s) continue;
        const up = r.kind === "rise";
        ctx.save(); ctx.fillStyle = color; ctx.shadowColor = "rgba(0,0,0,0.5)"; ctx.shadowBlur = 4;
        ctx.beginPath();
        if (up) { ctx.moveTo(s[0], s[1] - 30); ctx.lineTo(s[0] - 8, s[1] - 18); ctx.lineTo(s[0] + 8, s[1] - 18); }
        else { ctx.moveTo(s[0], s[1] - 16); ctx.lineTo(s[0] - 8, s[1] - 28); ctx.lineTo(s[0] + 8, s[1] - 28); }
        ctx.fill(); ctx.restore();
        text(fmtTime(r.t), s[0], s[1] - 44, { size: 14, weight: 600, color });
      }
    }
    if (opts.label) {
      const s = project(dp.apex.az, dp.apex.alt);
      if (s && s[1] > 170) text(opts.label, s[0], s[1] - 18, { size: 14, weight: 600, color });
    }
  }

  function drawSun(pos, when) {
    const s = project(pos.az, pos.alt);
    const below = pos.alt < -0.83;
    if (s && s[0] > -60 && s[0] < W + 60 && s[1] > -60 && s[1] < H + 60) {
      const r = 22;
      ctx.save();
      ctx.globalAlpha = below ? 0.55 : 1;
      ctx.fillStyle = "rgba(255,194,14,0.30)";
      ctx.beginPath(); ctx.arc(s[0], s[1], r * 1.75, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = "#FFC20E"; ctx.shadowColor = "rgba(0,0,0,0.35)"; ctx.shadowBlur = 8;
      ctx.beginPath(); ctx.arc(s[0], s[1], r, 0, Math.PI * 2); ctx.fill();
      ctx.restore();
      // eclipse: the Moon's disk crossing the marker, scaled with it
      if (S.eclipse && when >= S.eclipse.c1.getTime() - 1800000 && when <= S.eclipse.c4.getTime() + 1800000) {
        const md = Astro.sunMoonDisks(new Date(when), obs());
        const ms = project(md.moon.az, md.moon.alt + (pos.alt - md.sun.alt));
        if (ms) {
          const sunPx = F * md.rS * D2R, k = r / sunPx;
          const mx = s[0] + (ms[0] - s[0]) * k, my = s[1] + (ms[1] - s[1]) * k;
          ctx.save();
          ctx.beginPath(); ctx.arc(s[0], s[1], r * 1.75, 0, Math.PI * 2); ctx.clip();
          ctx.fillStyle = "#15181D"; ctx.strokeStyle = "rgba(255,255,255,0.35)"; ctx.lineWidth = 1;
          ctx.beginPath(); ctx.arc(mx, my, r * md.rM / md.rS, 0, Math.PI * 2); ctx.fill(); ctx.stroke();
          ctx.restore();
        }
      }
      return;
    }
    // off-screen: arrow at the edge pointing towards the sun
    const d = applyT(CAM, worldVec(pos.az, pos.alt));
    let dx = d[0], dy = -d[1];
    if (Math.hypot(dx, dy) < 1e-6) dx = 1;
    const n = Math.hypot(dx, dy); dx /= n; dy /= n;
    const mx = W / 2 - 46, my = H / 2 - 150;
    const k = Math.min(mx / Math.abs(dx || 1e-9), my / Math.abs(dy || 1e-9));
    const x = W / 2 + dx * k, y = H / 2 + dy * k, ang = Math.atan2(dy, dx);
    ctx.save();
    ctx.translate(x, y);
    ctx.globalAlpha = below ? 0.55 : 0.95;
    ctx.fillStyle = "#FFC20E"; ctx.shadowColor = "rgba(0,0,0,0.5)"; ctx.shadowBlur = 6;
    ctx.beginPath(); ctx.arc(0, 0, 11, 0, Math.PI * 2); ctx.fill();
    ctx.rotate(ang);
    ctx.beginPath(); ctx.moveTo(30, 0); ctx.lineTo(17, -9); ctx.lineTo(17, 9); ctx.closePath(); ctx.fill();
    ctx.restore();
  }

  function drawCrosshair(strong) {
    ctx.save();
    ctx.strokeStyle = strong ? "rgba(255,194,14,0.95)" : "rgba(255,255,255,0.75)"; ctx.lineWidth = strong ? 2 : 1.5;
    const L = strong ? 46 : 86, cx = W / 2, cy = H / 2;
    ctx.beginPath(); ctx.moveTo(cx - L, cy); ctx.lineTo(cx + L, cy); ctx.moveTo(cx, cy - L); ctx.lineTo(cx, cy + L); ctx.stroke();
    if (strong) { ctx.beginPath(); ctx.arc(cx, cy, 22, 0, Math.PI * 2); ctx.stroke(); }
    ctx.restore();
  }

  // ---------------------------------------------------------------- render loop
  let lastHud = 0, seasonCache = null;
  function seasonPaths(year) {
    const key = year + "|" + S.loc.lat.toFixed(3) + "|" + S.loc.lon.toFixed(3);
    if (seasonCache && seasonCache.key === key) return seasonCache;
    const s = Astro.seasons(year);
    seasonCache = { key, jun: dayPath(s.june), dec: dayPath(s.december), equ: dayPath(s.march), dates: s };
    return seasonCache;
  }

  function frame(ts) {
    requestAnimationFrame(frame);
    if (!S.started) return;
    if (S.playing && S.travel) {
      S.travel += 90000; // 1.5 min per frame ≈ a day in 16 s
      const d0 = dayStart(new Date(S.travel - 90000));
      if (dayStart(new Date(S.travel)).getTime() !== d0.getTime()) S.travel = d0.getTime();
      if (S.panel === "travel") syncTravel();
    }
    CAM = cameraMatrix(false); F = focal();
    const fwd = apply(CAM, [0, 0, -1]), up = apply(CAM, [0, 1, 0]);
    const camAz = Math.hypot(fwd[0], fwd[1]) > 0.15 ? headingOf(fwd) : headingOf(fwd[2] < 0 ? up : up.map(v => -v));
    const camAlt = Math.asin(clamp(fwd[2], -1, 1)) * R2D;

    ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
    ctx.clearRect(0, 0, W, H);
    const when = now();
    const o = obs();

    if (video.hidden) drawGround(camAz, camAlt);
    if (S.solstice) {
      const sp = seasonPaths(when.getFullYear());
      drawDayPath(sp.jun, "#FF8A50", { width: 3, dashAlpha: 0.5, label: fmtShortDate(sp.dates.june) });
      drawDayPath(sp.dec, "#82B1FF", { width: 3, dashAlpha: 0.5, label: fmtShortDate(sp.dates.december) });
      drawDayPath(sp.equ, "rgba(255,255,255,0.75)", { width: 2, dashAlpha: 0.4, label: t("equinox") });
    }
    drawHorizon(camAz);
    if (S.compare) drawDayPath(dayPath(S.compare), "#4FC3F7", { width: 4, hours: true, events: true, label: fmtShortDate(S.compare) });
    const dp = dayPath(when);
    drawDayPath(dp, "#FFC20E", { width: 5, hours: true, events: true, label: S.compare ? fmtShortDate(when) : null });
    const sp = Astro.sunPosition(when, o);
    drawSun(sp, when.getTime());
    drawCrosshair(S.panel === "calibrate");

    autoAlign(ts);
    if (ts - lastHud > 150) { lastHud = ts; updateHud(camAz, camAlt, sp, when); }
  }

  function updateHud(camAz, camAlt, sp, when) {
    $("headingTxt").textContent = dirName(camAz);
    $("headingDeg").textContent = Math.round(norm360(camAz)) + "° · " + (camAlt >= 0 ? "+" : "") + Math.round(camAlt) + "°";
    let r = "☀ " + Math.round(sp.az) + "° · " + sp.alt.toFixed(1) + "°";
    if (S.travel) r = fmtShortDate(when) + " " + fmtTime(when) + "  ·  " + r;
    $("readout").textContent = r;
    const chip = $("modeChip"), cs = compassState();
    let msg = null, cls = "chip warn";
    if (S.travel && S.panel !== "travel") msg = "⏱ " + t("timeTravel");
    else if (S.panel === "calibrate") msg = t("calibrating");
    else if (S.loc.src === "approx") { msg = t("waitLoc"); cls = "chip alert"; }
    else if (cs === "gyro") { msg = t("gyroOnly"); cls = "chip alert"; }
    else if (cs === "none") { msg = t("noCompass"); cls = "chip alert"; }
    else if (cs === "manual") msg = t("manual");
    chip.hidden = !msg; if (msg) { chip.textContent = msg; chip.className = cls; }
    if (S.panel === "calibrate") syncCalibrate();
  }

  // ---------------------------------------------------------------- pointer: look around / nudge calibration
  let drag = null;
  cv.addEventListener("pointerdown", e => {
    if (!(O.manual || S.panel === "calibrate")) return;
    drag = { x: e.clientX, y: e.clientY, x0: e.clientX, y0: e.clientY }; cv.setPointerCapture(e.pointerId);
  });
  cv.addEventListener("pointermove", e => {
    if (!drag) return;
    const k = S.cal.fov / Math.max(W, H) * (S.panel === "calibrate" && !O.manual ? 0.5 : 1);
    const dx = (e.clientX - drag.x) * k, dy = (e.clientY - drag.y) * k;
    drag.x = e.clientX; drag.y = e.clientY;
    if (S.panel === "calibrate" && !O.manual) { S.cal.yaw = wrap180(S.cal.yaw - dx); S.cal.pitch = clamp(S.cal.pitch + dy, -30, 30); store.set("cal", S.cal); }
    else { S.view.yaw = norm360(S.view.yaw - dx); S.view.pitch = clamp(S.view.pitch + dy, -85, 85); }
  });
  const endDrag = () => { drag = null; };
  cv.addEventListener("pointerup", e => {
    // a tap (not a drag) in calibrate mode: "this is where the real sun is"
    if (drag && S.panel === "calibrate" && !O.manual && Math.hypot(e.clientX - drag.x0, e.clientY - drag.y0) < 10) {
      const sun = Astro.sunPosition(new Date(), obs());
      if (sun.alt > -0.5) { alignPointToSun(e.clientX, e.clientY, sun); toast(t("aligned")); }
    }
    endDrag();
  }); cv.addEventListener("pointercancel", endDrag);
  cv.addEventListener("wheel", e => { if (O.manual) { S.cal.fov = clamp(S.cal.fov + e.deltaY * 0.03, 30, 110); e.preventDefault(); } }, { passive: false });

  // ---------------------------------------------------------------- UI helpers
  let toastTimer = 0;
  function toast(msg, ms) {
    const el = $("toast"); el.textContent = msg; el.hidden = false; el.style.opacity = 1;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { el.style.opacity = 0; setTimeout(() => { el.hidden = true; }, 260); }, ms || 2600);
  }
  function openMenu() {
    $("stTravel").hidden = !S.travel; $("stCompare").hidden = !S.compare; $("stSolstice").hidden = !S.solstice;
    $("menu").hidden = false;
  }
  const closeMenu = () => { $("menu").hidden = true; };
  function openSheet(html, onMount) {
    S.sheet = true;
    $("sheet").innerHTML = '<div class="grab"></div>' + html;
    $("sheetWrap").hidden = false;
    $("sheet").scrollTop = 0;
    if (onMount) onMount($("sheet"));
  }
  function closeSheet() { $("sheetWrap").hidden = true; S.sheet = null; }
  $("sheetWrap").addEventListener("click", e => { if (e.target === $("sheetWrap")) closeSheet(); });
  // swipe the sheet down to close
  (() => {
    let y0 = null;
    $("sheet").addEventListener("touchstart", e => { y0 = $("sheet").scrollTop <= 0 ? e.touches[0].clientY : null; }, { passive: true });
    $("sheet").addEventListener("touchend", e => { if (y0 !== null && e.changedTouches[0].clientY - y0 > 90) closeSheet(); y0 = null; }, { passive: true });
  })();
  function openPanel(name, html, onMount) {
    S.panel = name;
    $("panelBody").innerHTML = html;
    $("panel").hidden = false; $("bottombar").hidden = true;
    if (onMount) onMount($("panelBody"));
  }
  function closePanel() { S.panel = null; S.playing = false; $("panel").hidden = true; $("bottombar").hidden = false; }
  const esc = s => String(s).replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

  // ---------------------------------------------------------------- Time travel
  function openTravel() {
    if (!S.travel) S.travel = Date.now();
    openPanel("travel", `
      <div class="head"><span class="big" id="ttTime"></span><span class="sub" id="ttDate"></span></div>
      <input type="range" id="ttSlider" min="0" max="1439" step="1" aria-label="Time">
      <div class="row">
        <button class="btn small" id="ttPrev" aria-label="Previous day">‹ 1d</button>
        <input type="date" id="ttDateIn" aria-label="Date">
        <button class="btn small" id="ttNext" aria-label="Next day">1d ›</button>
        <button class="btn small" id="ttPlay" aria-label="Play">▶</button>
      </div>
      <div id="ttEcl"></div>
      <div class="row"><button class="btn" id="ttNow">${esc(t("now"))}</button><span style="flex:1"></span><button class="btn primary" id="ttDone">${esc(t("done"))}</button></div>`,
      el => {
        const setDay = delta => { const d = new Date(S.travel); d.setDate(d.getDate() + delta); S.travel = d.getTime(); syncTravel(); };
        el.querySelector("#ttSlider").addEventListener("input", e => {
          const d = new Date(S.travel), m = +e.target.value;
          S.travel = new Date(d.getFullYear(), d.getMonth(), d.getDate(), Math.floor(m / 60), m % 60).getTime(); S.playing = false; syncTravel(true);
        });
        el.querySelector("#ttPrev").onclick = () => setDay(-1);
        el.querySelector("#ttNext").onclick = () => setDay(1);
        el.querySelector("#ttDateIn").addEventListener("change", e => { if (e.target.value) { S.travel = parseDateInput(e.target.value, new Date(S.travel)).getTime(); syncTravel(); } });
        el.querySelector("#ttPlay").onclick = () => { S.playing = !S.playing; syncTravel(); };
        el.querySelector("#ttNow").onclick = () => { S.travel = null; S.eclipse = null; S.playing = false; closePanel(); };
        el.querySelector("#ttDone").onclick = () => { S.playing = false; closePanel(); };
        syncTravel();
      });
  }
  function syncTravel(fromSlider) {
    const el = $("panelBody"); if (S.panel !== "travel" || !S.travel) return;
    const d = new Date(S.travel);
    el.querySelector("#ttTime").textContent = fmtTime(d);
    el.querySelector("#ttDate").textContent = fmtDate(d);
    if (!fromSlider) el.querySelector("#ttSlider").value = d.getHours() * 60 + d.getMinutes();
    const di = el.querySelector("#ttDateIn"); if (document.activeElement !== di) di.value = dateInputValue(d);
    el.querySelector("#ttPlay").textContent = S.playing ? "❚❚" : "▶";
    const ecl = el.querySelector("#ttEcl");
    const E = S.eclipse;
    if (E && dayStart(d).getTime() === dayStart(E.max).getTime()) {
      if (!ecl.dataset.on) {
        ecl.dataset.on = 1;
        ecl.innerHTML = `<div class="sub" style="margin-bottom:6px">${esc(t("eclipse"))} · ${Math.round(E.obscuration * 100)}% ${esc(t("obsc"))}</div>
          <div class="row scroll">
            <button class="btn small" data-j="c1">${esc(t("begins"))} ${fmtTime(E.c1)}</button>
            <button class="btn small" data-j="max">${esc(t("max"))} ${fmtTime(E.max)}</button>
            <button class="btn small" data-j="c4">${esc(t("ends"))} ${fmtTime(E.c4)}</button></div>`;
        ecl.querySelectorAll("[data-j]").forEach(b => { b.onclick = () => { S.travel = E[b.dataset.j].getTime(); S.playing = false; syncTravel(); }; });
      }
    } else { ecl.innerHTML = ""; delete ecl.dataset.on; }
  }

  // ---------------------------------------------------------------- Compare dates
  function openCompare() {
    const base = now();
    if (!S.compare) { const s = Astro.seasons(base.getFullYear()); S.compare = base.getMonth() < 3 || base.getMonth() > 8 ? s.june : s.december; }
    openPanel("compare", `
      <div class="head"><span class="title">${esc(t("cmpTitle"))}</span><input type="date" id="cmpDate" aria-label="Date"></div>
      <div class="row scroll">
        <button class="btn small" data-p="jun">${esc(t("junSol"))}</button>
        <button class="btn small" data-p="dec">${esc(t("decSol"))}</button>
        <button class="btn small" data-p="mar">${esc(t("marEq"))}</button>
        <button class="btn small" data-p="m1">${esc(t("plus1m"))}</button>
        <button class="btn small" data-p="m6">${esc(t("plus6m"))}</button>
      </div>
      <div class="cmp" id="cmpTable"></div>
      <div class="row"><button class="btn" id="cmpOff">${esc(t("hideCmp"))}</button><span style="flex:1"></span><button class="btn primary" id="cmpDone">${esc(t("done"))}</button></div>`,
      el => {
        el.querySelector("#cmpDate").addEventListener("change", e => { if (e.target.value) { S.compare = parseDateInput(e.target.value); syncCompare(); } });
        el.querySelectorAll("[data-p]").forEach(b => b.onclick = () => {
          const b0 = now(), s = Astro.seasons(b0.getFullYear()), p = b.dataset.p;
          if (p === "jun") S.compare = s.june; else if (p === "dec") S.compare = s.december; else if (p === "mar") S.compare = s.march;
          else { const d = new Date(b0); d.setMonth(d.getMonth() + (p === "m1" ? 1 : 6)); S.compare = d; }
          syncCompare();
        });
        el.querySelector("#cmpOff").onclick = () => { S.compare = null; closePanel(); };
        el.querySelector("#cmpDone").onclick = closePanel;
        syncCompare();
      });
  }
  function syncCompare() {
    const el = $("panelBody"); if (S.panel !== "compare" || !S.compare) return;
    el.querySelector("#cmpDate").value = dateInputValue(S.compare);
    const a = dayPath(now()).ev, b = dayPath(S.compare).ev;
    const len = ev => ev.state === "normal" ? fmtDur(ev.dayLengthMs) : t(ev.state);
    el.querySelector("#cmpTable").innerHTML = `
      <span></span><b class="c1">${esc(fmtShortDate(now()))}</b><b class="c2">${esc(fmtShortDate(S.compare))}</b>
      <span class="lbl">${esc(t("sunrise"))}</span><span>${fmtTime(a.rise)}</span><span>${fmtTime(b.rise)}</span>
      <span class="lbl">${esc(t("sunset"))}</span><span>${fmtTime(a.set)}</span><span>${fmtTime(b.set)}</span>
      <span class="lbl">${esc(t("noonAlt"))}</span><span>${fmtDeg(a.noonAlt, 1)}</span><span>${fmtDeg(b.noonAlt, 1)}</span>
      <span class="lbl">${esc(t("daylength"))}</span><span>${esc(len(a))}</span><span>${esc(len(b))}</span>`;
  }

  // ---------------------------------------------------------------- Calibrate
  function openCalibrate() {
    openPanel("calibrate", `
      <div class="head"><span class="title">${esc(t("calibrate"))}</span><span class="sub" id="calCmp"></span></div>
      <p id="calHelp"></p>
      <label class="inline" for="calFov">${esc(t("fov"))} <span id="calFovV" style="min-width:44px;color:var(--ink)"></span><input type="range" id="calFov" min="35" max="100" step="0.5"></label>
      <div class="row"><button class="btn primary" id="calSun">${esc(t("alignSun"))}</button><button class="btn" id="calReset">${esc(t("reset"))}</button><span style="flex:1"></span><button class="btn" id="calDone">${esc(t("done"))}</button></div>
      <label class="inline"><input type="checkbox" id="calAuto" style="width:20px;height:20px;accent-color:var(--sun)"> ${esc(t("autoAlign"))}</label>
      <div class="sub" id="calOff"></div>`,
      el => {
        el.querySelector("#calSun").onclick = alignToSun;
        el.querySelector("#calReset").onclick = () => { S.cal.yaw = 0; S.cal.pitch = 0; S.cal.fov = 64; det.aligned = false; store.set("cal", S.cal); syncCalibrate(); };
        el.querySelector("#calFov").addEventListener("input", e => { S.cal.fov = +e.target.value; store.set("cal", S.cal); syncCalibrate(); });
        el.querySelector("#calDone").onclick = closePanel;
        const ca = el.querySelector("#calAuto");
        ca.checked = S.cal.auto !== false;
        ca.onchange = () => { S.cal.auto = ca.checked; store.set("cal", S.cal); };
        syncCalibrate();
      });
  }
  function syncCalibrate() {
    const el = $("panelBody"); if (S.panel !== "calibrate") return;
    const sun = Astro.sunPosition(new Date(), obs());
    const up = sun.alt > -0.5;
    el.querySelector("#calHelp").textContent = (up ? t("calHelp") : t("calHelpNight")) + (compassState() === "compass" ? "" : " " + t("figure8"));
    el.querySelector("#calSun").disabled = !up || O.manual;
    el.querySelector("#calOff").textContent = t("offset") + " " + (S.cal.yaw >= 0 ? "+" : "") + S.cal.yaw.toFixed(1) + "° / " + (S.cal.pitch >= 0 ? "+" : "") + S.cal.pitch.toFixed(1) + "°";
    const fv = el.querySelector("#calFov"); if (document.activeElement !== fv) fv.value = S.cal.fov;
    el.querySelector("#calFovV").textContent = fmtDeg(S.cal.fov, 1);
    const cs = compassState();
    el.querySelector("#calCmp").textContent = ({ compass: t("cmpGood"), gyro: t("cmpGyro"), none: t("cmpNone"), manual: t("cmpManual") }[cs])
      + (O.acc !== null && O.acc >= 0 && cs === "compass" ? " ±" + Math.round(O.acc) + "°" : "");
  }
  // Direction (az/alt) that a screen point looks at, with the current calibration.
  function screenDir(x, y, R) {
    const d = [(x - W / 2) / F, -(y - H / 2) / F, -1], n = Math.hypot(...d);
    const w = apply(R, d.map(v => v / n));
    return { az: headingOf(w), alt: Math.asin(clamp(w[2], -1, 1)) * R2D };
  }
  // Shift the calibration so that the screen point (x, y) shows the computed sun.
  function alignPointToSun(x, y, sun) {
    const p = screenDir(x, y, cameraMatrix(true));
    S.cal.yaw = wrap180(S.cal.yaw + wrap180(sun.az - p.az));
    S.cal.pitch = clamp(S.cal.pitch + (sun.alt - p.alt), -30, 30);
    store.set("cal", S.cal);
    O.q = null;
    syncCalibrate();
  }
  function alignToSun() {
    alignPointToSun(W / 2, H / 2, Astro.sunPosition(new Date(), obs()));
    toast(t("aligned"));
  }

  // Find the sun in the camera image: the largest compact blob of saturated pixels.
  const det = { cv: null, g: null, last: 0, prev: null, aligned: false, announced: false };
  function findSunInVideo() {
    const vw = video.videoWidth, vh = video.videoHeight;
    if (!vw || !vh) return null;
    const tw = 120, th = Math.max(1, Math.round(tw * vh / vw));
    if (!det.cv) { det.cv = document.createElement("canvas"); det.g = det.cv.getContext("2d", { willReadFrequently: true }); }
    if (det.cv.width !== tw || det.cv.height !== th) { det.cv.width = tw; det.cv.height = th; }
    det.g.drawImage(video, 0, 0, tw, th);
    let px;
    try { px = det.g.getImageData(0, 0, tw, th).data; } catch (e) { return null; }
    const N = tw * th, lum = new Uint8Array(N);
    let max = 0;
    for (let i = 0; i < N; i++) { const l = (px[i * 4] * 54 + px[i * 4 + 1] * 183 + px[i * 4 + 2] * 19) >> 8; lum[i] = l; if (l > max) max = l; }
    if (max < 245) return null;
    const thr = max - 4, lab = new Uint8Array(N), stack = [];
    let best = null;
    for (let i = 0; i < N; i++) {
      if (lum[i] < thr || lab[i]) continue;
      let area = 0, sx = 0, sy = 0, x0 = tw, x1 = 0, y0 = th, y1 = 0;
      lab[i] = 1; stack.push(i);
      while (stack.length) {
        const j = stack.pop(), x = j % tw, y = (j / tw) | 0;
        area++; sx += x; sy += y;
        if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y;
        if (x > 0 && !lab[j - 1] && lum[j - 1] >= thr) { lab[j - 1] = 1; stack.push(j - 1); }
        if (x < tw - 1 && !lab[j + 1] && lum[j + 1] >= thr) { lab[j + 1] = 1; stack.push(j + 1); }
        if (y > 0 && !lab[j - tw] && lum[j - tw] >= thr) { lab[j - tw] = 1; stack.push(j - tw); }
        if (y < th - 1 && !lab[j + tw] && lum[j + tw] >= thr) { lab[j + tw] = 1; stack.push(j + tw); }
      }
      if (!best || area > best.area) best = { area, cx: sx / area, cy: sy / area, w: x1 - x0 + 1, h: y1 - y0 + 1 };
    }
    if (!best || best.area < 3 || best.area > N * 0.08) return null;     // too small, or a bright cloud / overexposed sky
    const aspect = best.w / best.h;
    if (aspect < 0.45 || aspect > 2.2 || best.area / (best.w * best.h) < 0.4) return null; // not round: glint, window frame
    const sc = Math.max(W / vw, H / vh);
    const vx = (best.cx + 0.5) * vw / tw, vy = (best.cy + 0.5) * vh / th;
    return { x: W / 2 + (vx - vw / 2) * sc, y: H / 2 + (vy - vh / 2) * sc };
  }
  function autoAlign(ts) {
    if (!S.cal.auto || O.manual || !O.Rdev || video.hidden || S.panel === "calibrate" || ts - det.last < 400) return;
    det.last = ts;
    const sun = Astro.sunPosition(new Date(), obs());
    if (sun.alt < 1 || S.loc.src === "approx") { det.prev = null; return; }
    const blob = findSunInVideo();
    if (!blob) { det.prev = null; return; }
    const R = cameraMatrix(true), p = screenDir(blob.x, blob.y, R);
    const err = Math.hypot(wrap180(sun.az - p.az) * Math.cos(sun.alt * D2R), sun.alt - p.alt);
    // first alignment may correct a large compass error; afterwards only small drift
    if (err > (det.aligned ? 6 : 35)) { det.prev = null; return; }
    // the detection must be steady in the sky for ~1 s (phone held still, not a passing reflection)
    const steady = det.prev && Math.hypot(wrap180(p.az - det.prev.az) * Math.cos(p.alt * D2R), p.alt - det.prev.alt) < 0.8;
    det.prev = steady ? Object.assign(p, { n: det.prev.n + 1 }) : Object.assign(p, { n: 1 });
    if (det.prev.n < 3 || err < 0.4) return;
    alignPointToSun(blob.x, blob.y, sun);
    det.prev = null;
    det.aligned = true;
    if (!det.announced) { det.announced = true; toast(t("autoAligned"), 3500); }
  }

  // ---------------------------------------------------------------- Eclipses
  let eclCache = null;
  function eclipseDiagram(E) {
    const md = Astro.sunMoonDisks(E.max, obs());
    const R = 22, k = R / md.rS;
    const dx = wrap180(md.moon.az - md.sun.az) * Math.cos(md.sun.alt * D2R) * k, dy = -(md.moon.alt - md.sun.alt) * k;
    return `<svg viewBox="-32 -32 64 64" width="64" height="64" aria-hidden="true">
      <defs><clipPath id="c${E.max.getTime()}"><circle r="30"/></clipPath></defs>
      <circle r="${R}" fill="#FFC20E"/><g clip-path="url(#c${E.max.getTime()})"><circle cx="${dx.toFixed(2)}" cy="${dy.toFixed(2)}" r="${(R * md.rM / md.rS).toFixed(2)}" fill="#2C2C2E" stroke="rgba(255,255,255,.25)"/></g></svg>`;
  }
  function openEclipses() {
    openSheet(`<h2>${esc(t("eclTitle"))}</h2><p>${esc(t("eclIntro"))}</p><div id="eclList"><div class="empty">${esc(t("calcing"))}</div></div>`);
    setTimeout(() => {
      const key = S.loc.lat.toFixed(2) + "|" + S.loc.lon.toFixed(2) + "|" + dayStart(new Date()).getTime();
      if (!eclCache || eclCache.key !== key) eclCache = { key, list: Astro.upcomingEclipses(new Date(), obs(), 8, 30) };
      const list = eclCache.list, box = $("eclList");
      if (!box) return;
      if (!list.length) { box.innerHTML = `<div class="empty">${esc(t("noEcl"))}</div>`; return; }
      box.innerHTML = list.map((E, i) => {
        const here = { total: t("hereTotal"), annular: t("hereAnnular"), partial: t("herePartial") }[E.local];
        const notes = [E.risesEclipsed ? t("risesE") : "", E.setsEclipsed ? t("setsE") : ""].filter(Boolean).join(" · ");
        return `<button class="ecl" data-i="${i}">${eclipseDiagram(E)}<div>
          <div class="t1">${esc(fmtLongDate(E.max))}</div>
          <div class="t2">${esc(t(E.global))} · ${esc(here)} · ${Math.round(E.obscuration * 100)}% ${esc(t("obsc"))}</div>
          <div class="t2">${fmtTime(E.c1)} → ${fmtTime(E.max)} → ${fmtTime(E.c4)} · ${esc(t("sunAlt"))} ${fmtDeg(E.sunAltMax)}</div>
          ${notes ? `<div class="t3">${esc(notes)}</div>` : `<div class="t3">${esc(t("showSky"))} ›</div>`}
        </div></button>`;
      }).join("");
      box.querySelectorAll(".ecl").forEach(b => b.onclick = () => {
        const E = list[+b.dataset.i];
        S.eclipse = E; S.travel = E.max.getTime(); S.playing = false;
        closeSheet(); openTravel();
      });
    }, 30);
  }

  // ---------------------------------------------------------------- About / status
  function openAbout() {
    const o = obs(), ev = dayPath(new Date()).ev, cs = compassState();
    const locSrc = S.loc.src === "gps" ? t("gps") : S.loc.src === "manual" ? t("manualLoc") : t("approxLoc");
    openSheet(`
      <h2>${esc(t("about"))}</h2>
      <h3>${esc(t("howTitle"))}</h3><p>${esc(t("how"))}</p>
      <h3>${esc(t("offlineTitle"))}</h3><p>${esc(t("offline"))}</p>
      <h3>${esc(t("sensorsTitle"))}</h3><p>${esc(t("sensors"))}</p>
      <h3>${esc(t("accTitle"))}</h3><p>${esc(t("acc"))}</p>
      <h3>${esc(t("status"))}</h3>
      <dl class="kv">
        <dt>${esc(t("location"))}</dt><dd>${o.lat.toFixed(4)}, ${o.lon.toFixed(4)}<br><span style="color:var(--muted);font-size:13px">${esc(locSrc)}</span></dd>
        <dt>${esc(t("compass"))}</dt><dd>${esc({ compass: t("cmpGood"), gyro: t("cmpGyro"), none: t("cmpNone"), manual: t("cmpManual") }[cs])}</dd>
        <dt>${esc(t("declination"))}</dt><dd>${(O.decl >= 0 ? "+" : "") + O.decl.toFixed(1)}°</dd>
        <dt>${esc(t("calibration"))}</dt><dd>${(S.cal.yaw >= 0 ? "+" : "") + S.cal.yaw.toFixed(1)}° / ${(S.cal.pitch >= 0 ? "+" : "") + S.cal.pitch.toFixed(1)}° · FOV ${S.cal.fov.toFixed(0)}°${O.rawHeading !== undefined ? " · mag " + Math.round(O.rawHeading) + "°" + (O.acc !== null ? " ±" + Math.round(O.acc) : "") : ""}</dd>
        <dt>${esc(t("sunrise"))}</dt><dd>${fmtTime(ev.rise)}</dd>
        <dt>${esc(t("noon"))}</dt><dd>${fmtTime(ev.noon)} · ${fmtDeg(ev.noonAlt, 1)}</dd>
        <dt>${esc(t("sunset"))}</dt><dd>${fmtTime(ev.set)}</dd>
        <dt>${esc(t("daylength"))}</dt><dd>${ev.state === "normal" ? fmtDur(ev.dayLengthMs) : esc(t(ev.state))}</dd>
      </dl>
      <div class="row" style="margin-top:14px" id="locRow"><button class="btn small" id="locEdit">${esc(t("edit"))}</button><button class="btn small" id="locGps">${esc(t("useGps"))}</button></div>
      <div id="locForm" hidden style="margin-top:12px">
        <div class="row"><label class="field">${esc(t("lat"))}<input id="locLat" inputmode="decimal" value="${o.lat.toFixed(5)}"></label>
        <label class="field">${esc(t("lon"))}<input id="locLon" inputmode="decimal" value="${o.lon.toFixed(5)}"></label></div>
        <div class="row" style="margin-top:10px"><button class="btn primary small" id="locSave">${esc(t("save"))}</button></div>
      </div>`,
      el => {
        el.querySelector("#locEdit").onclick = () => { el.querySelector("#locForm").hidden = false; };
        el.querySelector("#locGps").onclick = () => { requestLocation(true); closeSheet(); };
        el.querySelector("#locSave").onclick = () => {
          const la = parseFloat(el.querySelector("#locLat").value.replace(",", ".")), lo = parseFloat(el.querySelector("#locLon").value.replace(",", "."));
          if (isFinite(la) && isFinite(lo) && Math.abs(la) <= 90 && Math.abs(lo) <= 180) { stopGps(); setLocation({ lat: la, lon: lo, h: 0, src: "manual" }); closeSheet(); }
        };
      });
  }

  function openLanguage() {
    openSheet(`<h2>${esc(t("language"))}</h2>
      <button class="choice" data-l="en">English <span class="tick">${S.lang === "en" ? "✓" : ""}</span></button>
      <button class="choice" data-l="lt">Lietuvių <span class="tick">${S.lang === "lt" ? "✓" : ""}</span></button>`,
      el => el.querySelectorAll("[data-l]").forEach(b => b.onclick = () => { setLang(b.dataset.l); closeSheet(); }));
  }
  function setLang(l) { S.lang = l; store.set("lang", l); applyI18n(); }

  // ---------------------------------------------------------------- location
  let gpsWatch = null;
  function setLocation(loc) {
    S.loc = loc; store.set("loc", loc);
    O.decl = Astro.magneticDeclination(loc.lat, loc.lon, new Date());
    pathCache.clear(); seasonCache = null; eclCache = null;
  }
  function stopGps() { if (gpsWatch !== null) { navigator.geolocation.clearWatch(gpsWatch); gpsWatch = null; } }
  function requestLocation(force) {
    if (!("geolocation" in navigator)) { if (S.loc.src === "approx") toast(t("noLoc"), 4000); return; }
    if (S.loc.src === "manual" && !force) return;
    stopGps();
    gpsWatch = navigator.geolocation.watchPosition(p => {
      const c = p.coords, prev = S.loc;
      const moved = prev.src !== "gps" || Math.abs(prev.lat - c.latitude) > 0.002 || Math.abs(prev.lon - c.longitude) > 0.002;
      if (moved) setLocation({ lat: c.latitude, lon: c.longitude, h: c.altitude || 0, src: "gps" });
    }, () => { if (S.loc.src === "approx") toast(t("noLoc"), 4000); }, { enableHighAccuracy: false, maximumAge: 300000, timeout: 30000 });
  }

  // ---------------------------------------------------------------- camera & photo
  async function startCamera() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) { toast(t("noCam"), 3500); return; }
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: false, video: { facingMode: { ideal: "environment" }, width: { ideal: 1920 }, height: { ideal: 1440 } } });
      video.srcObject = stream; video.hidden = false;
      await video.play().catch(() => {});
    } catch (e) { toast(t("noCam"), 3500); }
  }
  async function takePhoto() {
    const c = document.createElement("canvas");
    c.width = cv.width; c.height = cv.height;
    const g = c.getContext("2d");
    if (!video.hidden && video.videoWidth) {
      const vw = video.videoWidth, vh = video.videoHeight, sc = Math.max(c.width / vw, c.height / vh);
      g.drawImage(video, (c.width - vw * sc) / 2, (c.height - vh * sc) / 2, vw * sc, vh * sc);
    } else {
      const gr = g.createLinearGradient(0, 0, 0, c.height); gr.addColorStop(0, "#0E1C33"); gr.addColorStop(0.6, "#6C8DB0"); gr.addColorStop(1, "#15171B");
      g.fillStyle = gr; g.fillRect(0, 0, c.width, c.height);
    }
    g.drawImage(cv, 0, 0);
    const when = now();
    g.font = `600 ${14 * DPR}px ${getComputedStyle(document.body).fontFamily}`;
    g.fillStyle = "rgba(255,255,255,0.9)"; g.shadowColor = "rgba(0,0,0,0.6)"; g.shadowBlur = 4 * DPR;
    g.fillText(`${t("appName")} · ${fmtDate(when)} ${fmtTime(when)} · ${S.loc.lat.toFixed(3)}, ${S.loc.lon.toFixed(3)}`, 16 * DPR, c.height - 16 * DPR);
    const fl = $("flash"); fl.style.opacity = 0.8; setTimeout(() => { fl.style.opacity = 0; }, 120);
    const blob = await new Promise(r => c.toBlob(r, "image/jpeg", 0.92));
    if (!blob) return;
    const name = "sun-path-" + dateInputValue(when) + "-" + String(when.getHours()).padStart(2, "0") + String(when.getMinutes()).padStart(2, "0") + ".jpg";
    const file = new File([blob], name, { type: "image/jpeg" });
    if (navigator.canShare && navigator.canShare({ files: [file] })) {
      try { await navigator.share({ files: [file], title: t("appName") }); return; } catch (e) { if (e && e.name === "AbortError") return; }
    }
    const a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download = name;
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 4000);
    toast(t("saved"));
  }

  // ---------------------------------------------------------------- start
  async function start() {
    // iOS needs the permission prompt inside the tap handler
    try {
      if (window.DeviceOrientationEvent && typeof DeviceOrientationEvent.requestPermission === "function") await DeviceOrientationEvent.requestPermission();
    } catch (e) { /* denied — falls back to drag */ }
    window.addEventListener("deviceorientation", onOrientation);
    window.addEventListener("deviceorientationabsolute", onOrientationAbs);
    $("start").hidden = true; S.started = true;
    setLocation(S.loc);
    requestLocation(false);
    startCamera();
    setTimeout(() => { if (!O.events) { O.manual = true; toast(t("noSensors"), 3500); } }, 1600);
  }

  // ---------------------------------------------------------------- wiring
  $("startBtn").onclick = start;
  $("startLang").onclick = () => setLang(S.lang === "lt" ? "en" : "lt");
  $("btnMenu").onclick = openMenu;
  $("btnInfo").onclick = openAbout;
  $("btnShot").onclick = takePhoto;
  $("headingPill").onclick = () => { if (S.travel) openTravel(); };
  $("menu").addEventListener("click", e => {
    if (e.target === $("menu")) return closeMenu();
    const b = e.target.closest("button[data-act]"); if (!b) return;
    closeMenu();
    if (S.panel) closePanel();
    switch (b.dataset.act) {
      case "calibrate": openCalibrate(); break;
      case "travel": openTravel(); break;
      case "compare": openCompare(); break;
      case "solstice": S.solstice = !S.solstice; store.set("solstice", S.solstice); toast(S.solstice ? t("solOn") : t("solOff")); break;
      case "eclipses": openEclipses(); break;
      case "language": openLanguage(); break;
    }
  });
  document.addEventListener("keydown", e => { if (e.key === "Escape") { closeMenu(); closeSheet(); } });
  document.addEventListener("visibilitychange", () => { if (!document.hidden && video.srcObject) video.play().catch(() => {}); });

  applyI18n();
  requestAnimationFrame(frame);
  if ("serviceWorker" in navigator) navigator.serviceWorker.register("sw.js", { scope: "./" }).catch(() => {});
  // a newer version took over (service worker update): reload once if the user hasn't started yet
  if ("serviceWorker" in navigator) navigator.serviceWorker.addEventListener("controllerchange", () => { if (!S.started && !window.__reloaded) { window.__reloaded = true; location.reload(); } });
  window.__sunpath = { S, O, start, sunScreen: () => { const sp = Astro.sunPosition(new Date(), obs()); return CAM && project(sp.az, sp.alt); } };
})();
