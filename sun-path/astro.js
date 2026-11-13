/* Sun Path — astronomy core.
 * Everything runs on-device:
 *  - Sun: truncated VSOP87 (Meeus, "Astronomical Algorithms" ch. 25 / App. III), ~1 arcsecond.
 *  - Moon: Meeus ch. 47 (truncated ELP-2000/82, ~10" in longitude) — used for eclipses.
 *  - Eclipses: topocentric Sun/Moon disks searched at every new moon; contacts found by bisection.
 *  - Magnetic declination: IGRF-13 truncated to degree 4 with secular variation (±1–3°).
 */
(function (root) {
  "use strict";
  const D2R = Math.PI / 180, R2D = 180 / Math.PI;
  const sind = x => Math.sin(x * D2R), cosd = x => Math.cos(x * D2R), tand = x => Math.tan(x * D2R);
  const norm360 = x => { x %= 360; return x < 0 ? x + 360 : x; };
  const wrap180 = x => { x = norm360(x); return x > 180 ? x - 360 : x; };
  const AU_KM = 149597870.7, EARTH_R = 6378.137;
  const SUN_R = 696000, MOON_R_PEN = 1737.4 * 1.00042, MOON_R_UMB = 1736.0; // k = 0.2725076 / 0.2722810 of Earth radius

  const jdFromDate = d => d.getTime() / 86400000 + 2440587.5;
  const dateFromJd = jd => new Date(Math.round((jd - 2440587.5) * 86400000));

  // ΔT = TT − UT in seconds. Near-present values are almost flat around 69 s.
  function deltaT(jd) {
    const y = 2000 + (jd - 2451544.5) / 365.25;
    if (y > 1990 && y < 2150) { const u = y - 2026; return 69.2 + 0.3 * u + 0.005 * u * u; }
    const u = (y - 1820) / 100; return -20 + 32 * u * u;
  }

  function nutation(T) {
    const om = 125.04452 - 1934.136261 * T, L = 280.4665 + 36000.7698 * T, Lp = 218.3165 + 481267.8813 * T;
    const dpsi = (-17.20 * sind(om) - 1.32 * sind(2 * L) - 0.23 * sind(2 * Lp) + 0.21 * sind(2 * om)) / 3600;
    const deps = (9.20 * cosd(om) + 0.57 * cosd(2 * L) + 0.10 * cosd(2 * Lp) - 0.09 * cosd(2 * om)) / 3600;
    const eps0 = 23.43929111 - 0.0130041667 * T - 1.6389e-7 * T * T + 5.0361e-7 * T * T * T;
    return { dpsi, eps: eps0 + deps };
  }

  // VSOP87 Earth series truncated as in Meeus, Appendix III: [A, B, C] → A·cos(B + C·τ), τ in Julian millennia.
  const VL = [
    [[175347046,0,0],[3341656,4.6692568,6283.07585],[34894,4.6261,12566.1517],[3497,2.7441,5753.3849],[3418,2.8289,3.5231],
     [3136,3.6277,77713.7715],[2676,4.4181,7860.4194],[2343,6.1352,3930.2097],[1324,0.7425,11506.7698],[1273,2.0371,529.691],
     [1199,1.1096,1577.3435],[990,5.233,5884.927],[902,2.045,26.298],[857,3.508,398.149],[780,1.179,5223.694],
     [753,2.533,5507.553],[505,4.583,18849.228],[492,4.205,775.523],[357,2.92,0.067],[317,5.849,11790.629],
     [284,1.899,796.298],[271,0.315,10977.079],[243,0.345,5486.778],[206,4.806,2544.314],[205,1.869,5573.143],
     [202,2.458,6069.777],[156,0.833,213.299],[132,3.411,2942.463],[126,1.083,20.775],[115,0.645,0.98],
     [103,0.636,4694.003],[102,0.976,15720.839],[102,4.267,7.114],[99,6.21,2146.17],[98,0.68,155.42],
     [86,5.98,161000.69],[85,1.3,6275.96],[85,3.67,71430.7],[80,1.81,17260.15],[79,3.04,12036.46],
     [75,1.76,5088.63],[74,3.5,3154.69],[74,4.68,801.82],[70,0.83,9437.76],[62,3.98,8827.39],
     [61,1.82,7084.9],[57,2.78,6286.6],[56,4.39,14143.5],[56,3.47,6279.55],[52,0.19,12139.55],
     [52,1.33,1748.02],[51,0.28,5856.48],[49,0.49,1194.45],[41,5.37,8429.24],[41,2.4,19651.05],
     [39,6.17,10447.39],[37,6.04,10213.29],[37,2.57,1059.38],[36,1.71,2352.87],[36,1.78,6812.77],
     [33,0.59,17789.85],[30,0.44,83996.85],[30,2.74,1349.87],[25,3.16,4690.48]],
    [[628331966747,0,0],[206059,2.678235,6283.07585],[4303,2.6351,12566.1517],[425,1.59,3.523],[119,5.796,26.298],
     [109,2.966,1577.344],[93,2.59,18849.23],[72,1.14,529.69],[68,1.87,398.15],[67,4.41,5507.55],
     [59,2.89,5223.69],[56,2.17,155.42],[45,0.4,796.3],[36,0.47,775.52],[29,2.65,7.11],
     [21,5.34,0.98],[19,1.85,5486.78],[19,4.97,213.3],[17,2.99,6275.96],[16,0.03,2544.31],
     [16,1.43,2146.17],[15,1.21,10977.08],[12,2.83,1748.02],[12,3.26,5088.63],[12,5.27,1194.45],
     [12,2.08,4694],[11,0.77,553.57],[10,1.3,6286.6],[10,4.24,1349.87],[9,2.7,242.73],
     [9,5.64,951.72],[8,5.3,2352.87],[6,2.65,9437.76],[6,4.67,4690.48]],
    [[52919,0,0],[8720,1.0721,6283.0758],[309,0.867,12566.152],[27,0.05,3.52],[16,5.19,26.3],
     [16,3.68,155.42],[10,0.76,18849.23],[9,2.06,77713.77],[7,0.83,775.52],[5,4.66,1577.34],
     [4,1.03,7.11],[4,3.44,5573.14],[3,5.14,796.3],[3,6.05,5507.55],[3,1.19,242.73],
     [3,6.12,529.69],[3,0.31,398.15],[3,2.28,553.57],[2,4.38,5223.69],[2,3.75,0.98]],
    [[289,5.844,6283.076],[35,0,0],[17,5.49,12566.15],[3,5.2,155.42],[1,4.72,3.52],[1,5.3,18849.23],[1,5.97,242.73]],
    [[114,3.142,0],[8,4.13,6283.08],[1,3.84,12566.15]],
    [[1,3.14,0]]
  ];
  const VB = [
    [[280,3.199,84334.662],[102,5.422,5507.553],[80,3.88,5223.69],[44,3.7,2352.87],[32,4,1577.34]],
    [[9,3.9,5507.55],[6,1.73,5223.69]]
  ];
  const VR = [
    [[100013989,0,0],[1670700,3.0984635,6283.07585],[13956,3.05525,12566.1517],[3084,5.1985,77713.7715],[1628,1.1739,5753.3849],
     [1576,2.8469,7860.4194],[925,5.453,11506.77],[542,4.564,3930.21],[472,3.661,5884.927],[346,0.964,5507.553],
     [329,5.9,5223.694],[307,0.299,5573.143],[243,4.273,11790.629],[212,5.847,1577.344],[186,5.022,10977.079],
     [175,3.012,18849.228],[110,5.055,5486.778],[98,0.89,6069.78],[86,5.69,15720.84],[86,1.27,161000.69],
     [65,0.27,17260.15],[63,0.92,529.69],[57,2.01,83996.85],[56,5.24,71430.7],[49,3.25,2544.31],
     [47,2.58,775.52],[45,5.54,9437.76],[43,6.01,6275.96],[39,5.36,4694],[38,2.39,8827.39],
     [37,0.83,19651.05],[37,4.9,12139.55],[36,1.67,12036.46],[35,1.84,2942.46],[33,0.24,7084.9],
     [32,0.18,5088.63],[32,1.78,398.15],[28,1.21,6286.6],[28,1.9,6279.55],[26,4.59,10447.39]],
    [[103019,1.10749,6283.07585],[1721,1.0644,12566.1517],[702,3.142,0],[32,1.02,18849.23],[31,2.84,5507.55],
     [25,1.32,5223.69],[18,1.42,1577.34],[10,5.91,10977.08],[9,1.42,6275.96],[9,0.27,5486.78]],
    [[4359,5.7846,6283.0758],[124,5.579,12566.152],[12,3.14,0],[9,3.63,77713.77],[6,1.87,5573.14],[3,5.47,18849.23]],
    [[145,4.273,6283.076],[7,3.92,12566.15]],
    [[4,2.56,6283.08]]
  ];
  function vsop(series, tau) {
    let sum = 0, tp = 1;
    for (const terms of series) {
      let s = 0;
      for (const [a, b, c] of terms) s += a * Math.cos(b + c * tau);
      sum += s * tp; tp *= tau;
    }
    return sum / 1e8;
  }

  // Geocentric apparent ecliptic coordinates of the Sun (Meeus ch. 25, higher accuracy).
  function sunEcl(T, nut) {
    const tau = T / 10;
    const L = vsop(VL, tau) * R2D, B = vsop(VB, tau) * R2D, R = vsop(VR, tau);
    let lam = L + 180, beta = -B;
    // conversion to the FK5 system
    const lp = lam - 1.397 * T - 0.00031 * T * T;
    lam += (-0.09033 + 0.03916 * (cosd(lp) + sind(lp)) * tand(beta)) / 3600;
    beta += 0.03916 * (cosd(lp) - sind(lp)) / 3600;
    lam += nut.dpsi - 20.4898 / 3600 / R;
    return { lam: norm360(lam), beta, distKm: R * AU_KM, R };
  }

  // Meeus Table 47.A: D, M, M', F, Σl (1e-6°), Σr (1e-3 km)
  const MOON_LR = [
    [0,0,1,0,6288774,-20905355],[2,0,-1,0,1274027,-3699111],[2,0,0,0,658314,-2955968],[0,0,2,0,213618,-569925],
    [0,1,0,0,-185116,48888],[0,0,0,2,-114332,-3149],[2,0,-2,0,58793,246158],[2,-1,-1,0,57066,-152138],
    [2,0,1,0,53322,-170733],[2,-1,0,0,45758,-204586],[0,1,-1,0,-40923,-129620],[1,0,0,0,-34720,108743],
    [0,1,1,0,-30383,104755],[2,0,0,-2,15327,10321],[0,0,1,2,-12528,0],[0,0,1,-2,10980,79661],
    [4,0,-1,0,10675,-34782],[0,0,3,0,10034,-23210],[4,0,-2,0,8548,-21636],[2,1,-1,0,-7888,24208],
    [2,1,0,0,-6766,30824],[1,0,-1,0,-5163,-8379],[1,1,0,0,4987,-16675],[2,-1,1,0,4036,-12831],
    [2,0,2,0,3994,-10445],[4,0,0,0,3861,-11650],[2,0,-3,0,3665,14403],[0,1,-2,0,-2689,-7003],
    [2,0,-1,2,-2602,0],[2,-1,-2,0,2390,10056],[1,0,1,0,-2348,6322],[2,-2,0,0,2236,-9884],
    [0,1,2,0,-2120,5751],[0,2,0,0,-2069,0],[2,-2,-1,0,2048,-4950],[2,0,1,-2,-1773,4130],
    [2,0,0,2,-1595,0],[4,-1,-1,0,1215,-3958],[0,0,2,2,-1110,0],[3,0,-1,0,-892,3258],
    [2,1,1,0,-810,2616],[4,-1,-2,0,759,-1897],[0,2,-1,0,-713,-2117],[2,2,-1,0,-700,2354],
    [2,1,-2,0,691,0],[2,-1,0,-2,596,0],[4,0,1,0,549,-1423],[0,0,4,0,537,-1117],
    [4,-1,0,0,520,-1571],[1,0,-2,0,-487,-1739],[2,1,0,-2,-399,0],[0,0,2,-2,-381,-4421],
    [1,1,1,0,351,0],[3,0,-2,0,-340,0],[4,0,-3,0,330,0],[2,-1,2,0,327,0],
    [0,2,1,0,-323,1165],[1,1,-1,0,299,0],[2,0,3,0,294,0],[2,0,-1,-2,0,8752]
  ];
  // Meeus Table 47.B: D, M, M', F, Σb (1e-6°)
  const MOON_B = [
    [0,0,0,1,5128122],[0,0,1,1,280602],[0,0,1,-1,277693],[2,0,0,-1,173237],[2,0,-1,1,55413],
    [2,0,-1,-1,46271],[2,0,0,1,32573],[0,0,2,1,17198],[2,0,1,-1,9266],[0,0,2,-1,8822],
    [2,-1,0,-1,8216],[2,0,-2,-1,4324],[2,0,1,1,4200],[2,1,0,-1,-3359],[2,-1,-1,1,2463],
    [2,-1,0,1,2211],[2,-1,-1,-1,2065],[0,1,-1,-1,-1870],[4,0,-1,-1,1828],[0,1,0,1,-1794],
    [0,0,0,3,-1749],[0,1,-1,1,-1565],[1,0,0,1,-1491],[0,1,1,1,-1475],[0,1,1,-1,-1410],
    [0,1,0,-1,-1344],[1,0,0,-1,-1335],[0,0,3,1,1107],[4,0,0,-1,1021],[4,0,-1,1,833],
    [0,0,1,-3,777],[4,0,-2,1,671],[2,0,0,-3,607],[2,0,2,-1,596],[2,-1,1,-1,491],
    [2,0,-2,1,-451],[0,0,3,-1,439],[2,0,2,1,422],[2,0,-3,-1,421],[2,1,-1,1,-366],
    [2,1,0,1,-351],[4,0,0,1,331],[2,-1,1,1,315],[2,-2,0,-1,302],[0,0,1,3,-283],
    [2,1,1,-1,-229],[1,1,0,-1,223],[1,1,0,1,223],[0,1,-2,-1,-220],[2,1,-1,-1,-220],
    [1,0,1,1,-185],[2,-1,-2,-1,181],[0,1,2,1,-177],[4,0,-2,-1,176],[4,-1,-1,-1,166],
    [1,0,1,-1,-164],[4,0,1,-1,132],[1,0,-1,-1,-119],[4,-1,0,-1,115],[2,-2,0,1,107]
  ];

  // Geocentric apparent ecliptic coordinates of the Moon.
  function moonEcl(T, nut) {
    const T2 = T * T, T3 = T2 * T, T4 = T3 * T;
    const Lp = norm360(218.3164477 + 481267.88123421 * T - 0.0015786 * T2 + T3 / 538841 - T4 / 65194000);
    const D = norm360(297.8501921 + 445267.1114034 * T - 0.0018819 * T2 + T3 / 545868 - T4 / 113065000);
    const M = norm360(357.5291092 + 35999.0502909 * T - 0.0001536 * T2 + T3 / 24490000);
    const Mp = norm360(134.9633964 + 477198.8675055 * T + 0.0087414 * T2 + T3 / 69699 - T4 / 14712000);
    const F = norm360(93.2720950 + 483202.0175233 * T - 0.0036539 * T2 - T3 / 3526000 + T4 / 863310000);
    const A1 = 119.75 + 131.849 * T, A2 = 53.09 + 479264.290 * T, A3 = 313.45 + 481266.484 * T;
    const E = 1 - 0.002516 * T - 0.0000074 * T2, E2 = E * E;
    let sl = 0, sr = 0, sb = 0;
    for (const [d, m, mp, f, l, r] of MOON_LR) {
      const arg = d * D + m * M + mp * Mp + f * F;
      const ef = m === 0 ? 1 : (Math.abs(m) === 1 ? E : E2);
      sl += l * ef * sind(arg); sr += r * ef * cosd(arg);
    }
    for (const [d, m, mp, f, b] of MOON_B) {
      const ef = m === 0 ? 1 : (Math.abs(m) === 1 ? E : E2);
      sb += b * ef * sind(d * D + m * M + mp * Mp + f * F);
    }
    sl += 3958 * sind(A1) + 1962 * sind(Lp - F) + 318 * sind(A2);
    sb += -2235 * sind(Lp) + 382 * sind(A3) + 175 * sind(A1 - F) + 175 * sind(A1 + F) + 127 * sind(Lp - Mp) - 115 * sind(Lp + Mp);
    return { lam: norm360(Lp + sl / 1e6 + nut.dpsi), lamTrue: norm360(Lp + sl / 1e6), beta: sb / 1e6, distKm: 385000.56 + sr / 1000 };
  }

  function eclToEqVec(lam, beta, eps, dist) {
    const cb = cosd(beta);
    const x = cb * cosd(lam), y = cb * sind(lam), z = sind(beta);
    return [dist * x, dist * (y * cosd(eps) - z * sind(eps)), dist * (y * sind(eps) + z * cosd(eps))];
  }

  function gast(jdUT, nut) {
    const d = jdUT - 2451545.0, T = d / 36525;
    const gmst = 280.46061837 + 360.98564736629 * d + 0.000387933 * T * T - T * T * T / 38710000;
    return norm360(gmst + nut.dpsi * cosd(nut.eps));
  }

  function observerVec(lat, lon, hM, lst) {
    const u = Math.atan(0.99664719 * tand(lat));
    const rs = 0.99664719 * Math.sin(u) + (hM / 6378140) * sind(lat);
    const rc = Math.cos(u) + (hM / 6378140) * cosd(lat);
    return [EARTH_R * rc * cosd(lst), EARTH_R * rc * sind(lst), EARTH_R * rs];
  }

  // degrees to add to geometric altitude (standard atmosphere, Saemundsson). Below the horizon the
  // lift fades out smoothly instead of jumping to zero, so drawn paths stay smooth there.
  function refraction(h) {
    const R = x => 1.02 / tand(x + 10.3 / (x + 5.11)) / 60;
    if (h >= -1) return R(h);
    if (h <= -5) return 0;
    const k = (h + 5) / 4;
    return R(-1) * k * k * (3 - 2 * k);
  }

  // Everything needed at one instant: topocentric vectors for Sun (and optionally Moon).
  function context(date, obs, withMoon) {
    const jdUT = jdFromDate(date), jde = jdUT + deltaT(jdUT) / 86400, T = (jde - 2451545) / 36525;
    const nut = nutation(T);
    const s = sunEcl(T, nut);
    const lst = norm360(gast(jdUT, nut) + obs.lon);
    const o = observerVec(obs.lat, obs.lon, obs.h || 0, lst);
    const sv = eclToEqVec(s.lam, s.beta, nut.eps, s.distKm);
    const ctx = { jdUT, lst, nut, sunEcl: s, sun: [sv[0] - o[0], sv[1] - o[1], sv[2] - o[2]] };
    if (withMoon) {
      const m = moonEcl(T, nut);
      const mv = eclToEqVec(m.lam, m.beta, nut.eps, m.distKm);
      ctx.moonEcl = m; ctx.moonGeo = mv; ctx.sunGeo = sv;
      ctx.moon = [mv[0] - o[0], mv[1] - o[1], mv[2] - o[2]];
    }
    return ctx;
  }

  function horizontal(v, lst, lat) {
    const r = Math.hypot(v[0], v[1], v[2]);
    const ra = Math.atan2(v[1], v[0]) * R2D, dec = Math.asin(v[2] / r) * R2D;
    const H = lst - ra;
    const alt = Math.asin(sind(lat) * sind(dec) + cosd(lat) * cosd(dec) * cosd(H)) * R2D;
    const az = norm360(Math.atan2(sind(H), cosd(H) * sind(lat) - tand(dec) * cosd(lat)) * R2D + 180);
    return { az, alt, ra: norm360(ra), dec, dist: r };
  }

  /** Sun position. alt is apparent (refracted); altGeo is geometric. */
  function sunPosition(date, obs) {
    const c = context(date, obs, false);
    const h = horizontal(c.sun, c.lst, obs.lat);
    return { az: h.az, altGeo: h.alt, alt: h.alt + refraction(h.alt), ra: h.ra, dec: h.dec, distKm: h.dist };
  }

  function moonPosition(date, obs) {
    const c = context(date, obs, true);
    const h = horizontal(c.moon, c.lst, obs.lat);
    return { az: h.az, altGeo: h.alt, alt: h.alt + refraction(h.alt), ra: h.ra, dec: h.dec, distKm: h.dist };
  }

  // Root of f between a and b (f(a), f(b) of opposite sign), on millisecond timestamps.
  function bisect(f, a, b, fa, tolMs) {
    for (let i = 0; i < 60 && b - a > tolMs; i++) {
      const m = (a + b) / 2, fm = f(m);
      if ((fm > 0) === (fa > 0)) { a = m; fa = fm; } else b = m;
    }
    return (a + b) / 2;
  }
  function goldenMin(f, a, b, tolMs) {
    const g = 0.6180339887;
    let c = b - g * (b - a), d = a + g * (b - a), fc = f(c), fd = f(d);
    while (b - a > tolMs) {
      if (fc < fd) { b = d; d = c; fd = fc; c = b - g * (b - a); fc = f(c); }
      else { a = c; c = d; fc = fd; d = a + g * (b - a); fd = f(d); }
    }
    return (a + b) / 2;
  }

  // Rise, set and highest point for the day starting at t0 (ms).
  // f = altitude above the rise/set threshold; apparent = altitude to report at the highest point.
  function dayEvents(t0, f, apparent) {
    let rise = null, set = null, prev = f(t0);
    const step = 10 * 60000;
    for (let t = t0 + step; t <= t0 + 86400000; t += step) {
      const cur = f(t);
      if (prev < 0 && cur >= 0 && !rise) rise = new Date(bisect(f, t - step, t, prev, 1000));
      if (prev >= 0 && cur < 0 && !set) set = new Date(bisect(f, t - step, t, prev, 1000));
      prev = cur;
    }
    let best = t0, bestAlt = -99;
    for (let t = t0; t <= t0 + 86400000; t += 30 * 60000) { const a = f(t); if (a > bestAlt) { bestAlt = a; best = t; } }
    const noonT = goldenMin(t => -f(t), best - 30 * 60000, best + 30 * 60000, 1000);
    let state = "normal";
    if (!rise && !set) state = f(noonT) > 0 ? "polarDay" : "polarNight";
    const dayLengthMs = rise && set ? (set > rise ? set - rise : 86400000 - (rise - set)) : (state === "polarDay" ? 86400000 : 0);
    return { rise, set, noon: new Date(noonT), noonAlt: apparent(noonT), state, dayLengthMs };
  }

  /** Sunrise, sunset and solar noon for the local calendar day containing `dayStart` (local midnight). */
  function sunEvents(dayStart, obs) {
    return dayEvents(dayStart.getTime(), t => sunPosition(new Date(t), obs).altGeo + 0.8333, t => sunPosition(new Date(t), obs).alt);
  }

  /** Moonrise, moonset and the Moon's highest point (upper limb on the horizon). */
  function moonEvents(dayStart, obs) {
    return dayEvents(dayStart.getTime(), t => {
      const p = moonPosition(new Date(t), obs);
      return p.altGeo + 0.5667 + Math.asin(1737.4 / p.distKm) * R2D;
    }, t => moonPosition(new Date(t), obs).alt);
  }

  /** Moon phase: illuminated fraction, waxing, index 0 new … 4 full … 7 waning crescent. */
  function moonPhase(date) {
    const jd = jdFromDate(date), T = (jd + deltaT(jd) / 86400 - 2451545) / 36525, n = nutation(T);
    const s = sunEcl(T, n), m = moonEcl(T, n);
    const sv = eclToEqVec(s.lam, s.beta, n.eps, s.distKm), mv = eclToEqVec(m.lam, m.beta, n.eps, m.distKm);
    const psi = vAngle(sv, mv), ls = Math.hypot(...sv), lm = Math.hypot(...mv);
    const i = Math.atan2(ls * Math.sin(psi), lm - ls * Math.cos(psi));
    const dl = norm360(m.lam - s.lam);
    return { illum: (1 + Math.cos(i)) / 2, waxing: dl < 180, index: Math.round(dl / 45) % 8 };
  }

  /** Time when the Sun's apparent longitude reaches `target` degrees, near `guess` (Date). */
  function sunLongitudeTime(target, guess) {
    let t = guess.getTime();
    for (let i = 0; i < 8; i++) {
      const jd = jdFromDate(new Date(t)), T = (jd + deltaT(jd) / 86400 - 2451545) / 36525;
      const lam = sunEcl(T, nutation(T)).lam;
      const diff = wrap180(target - lam);
      t += diff / 0.98564736 * 86400000;
      if (Math.abs(diff) < 1e-6) break;
    }
    return new Date(t);
  }
  function seasons(year) {
    return {
      march: sunLongitudeTime(0, new Date(Date.UTC(year, 2, 20))),
      june: sunLongitudeTime(90, new Date(Date.UTC(year, 5, 21))),
      september: sunLongitudeTime(180, new Date(Date.UTC(year, 8, 22))),
      december: sunLongitudeTime(270, new Date(Date.UTC(year, 11, 21)))
    };
  }

  // ---------- Solar eclipses ----------
  const vAngle = (a, b) => {
    const dot = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    const cx = a[1] * b[2] - a[2] * b[1], cy = a[2] * b[0] - a[0] * b[2], cz = a[0] * b[1] - a[1] * b[0];
    return Math.atan2(Math.hypot(cx, cy, cz), dot); // radians, stable for small angles
  };
  function diskState(t, obs) {
    const c = context(new Date(t), obs, true);
    const ds = Math.hypot(...c.sun), dm = Math.hypot(...c.moon);
    const sep = vAngle(c.sun, c.moon);
    const rS = Math.asin(SUN_R / ds), rMp = Math.asin(MOON_R_PEN / dm), rMu = Math.asin(MOON_R_UMB / dm);
    return { c, sep, rS, rMp, rMu };
  }
  function newMoonAfter(t) {
    // geocentric conjunction in ecliptic longitude, via Newton iterations (relative motion ~12.19°/day)
    const elong = tt => {
      const jd = jdFromDate(new Date(tt)), T = (jd + deltaT(jd) / 86400 - 2451545) / 36525, n = nutation(T);
      return wrap180(moonEcl(T, n).lam - sunEcl(T, n).lam);
    };
    let e = elong(t);
    t += (norm360(-e) || 360) / 12.19 * 86400000;
    for (let i = 0; i < 6; i++) { e = elong(t); t -= e / 12.19 * 86400000; if (Math.abs(e) < 1e-5) break; }
    return t;
  }
  function overlapArea(rS, rM, d) { // area of overlap of two disks, fraction of Sun's disk
    if (d >= rS + rM) return 0;
    if (d <= Math.abs(rM - rS)) return rM >= rS ? 1 : (rM * rM) / (rS * rS);
    const a = rS * rS * Math.acos((d * d + rS * rS - rM * rM) / (2 * d * rS));
    const b = rM * rM * Math.acos((d * d + rM * rM - rS * rS) / (2 * d * rM));
    const c = 0.5 * Math.sqrt((-d + rS + rM) * (d + rS - rM) * (d - rS + rM) * (d + rS + rM));
    return (a + b - c) / (Math.PI * rS * rS);
  }
  // Global character of the eclipse from the shadow axis (independent of observer).
  function globalKind(tNM) {
    const geo = { lat: 0, lon: 0, h: 0 };
    const axis = t => {
      const c = context(new Date(t), geo, true);
      const S = c.sunGeo, M = c.moonGeo;
      const u = [M[0] - S[0], M[1] - S[1], M[2] - S[2]], ul = Math.hypot(...u);
      u[0] /= ul; u[1] /= ul; u[2] /= ul;
      const along = -(M[0] * u[0] + M[1] * u[1] + M[2] * u[2]); // Moon→Earth-centre distance along the axis
      const px = M[0] + along * u[0], py = M[1] + along * u[1], pz = M[2] + along * u[2];
      return { gamma: Math.hypot(px, py, pz) / EARTH_R, along, sunMoon: ul };
    };
    const tm = goldenMin(t => axis(t).gamma, tNM - 4 * 3600000, tNM + 4 * 3600000, 5000);
    const a = axis(tm);
    const umbraLen = a.sunMoon * MOON_R_UMB / (SUN_R - MOON_R_UMB);
    const reach = a.along - EARTH_R * Math.sqrt(Math.max(0, 1 - a.gamma * a.gamma)); // to Earth's surface on the axis
    let kind = "partial";
    if (a.gamma < 0.9972) kind = umbraLen > reach ? (umbraLen > a.along ? "total" : "hybrid") : "annular";
    if (kind === "hybrid") kind = "total";
    return { kind, gamma: a.gamma, time: new Date(tm) };
  }

  /** Local circumstances of the solar eclipse near geocentric new moon tNM, or null. */
  function localEclipse(tNM, obs) {
    const f = t => { const s = diskState(t, obs); return s.sep - s.rS - s.rMp; };
    const W = 5 * 3600000;
    // coarse scan for the minimum separation
    let best = tNM, bestV = Infinity;
    for (let t = tNM - W; t <= tNM + W; t += 120000) { const v = f(t); if (v < bestV) { bestV = v; best = t; } }
    if (bestV >= 0) return null;
    const tMax = goldenMin(t => diskState(t, obs).sep, best - 240000, best + 240000, 500);
    const sMax = diskState(tMax, obs);
    const c1 = bisect(f, tMax - W, tMax, f(tMax - W), 500);
    const c4 = bisect(f, tMax, tMax + W, sMax.sep - sMax.rS - sMax.rMp, 500);
    let c2 = null, c3 = null;
    const g = t => { const s = diskState(t, obs); return s.sep - Math.abs(s.rMu - s.rS); };
    const gMax = g(tMax);
    if (gMax < 0) {
      c2 = bisect(g, tMax - 600000, tMax, g(tMax - 600000), 200);
      c3 = bisect(g, tMax, tMax + 600000, gMax, 200);
    }
    const alt = t => sunPosition(new Date(t), obs);
    const pMax = alt(tMax);
    const local = c2 ? (sMax.rMu > sMax.rS ? "total" : "annular") : "partial";
    // visibility: is the Sun up at any time between C1 and C4?
    let visibleFrom = null, visibleTo = null;
    const N = 60;
    for (let i = 0; i <= N; i++) {
      const t = c1 + (c4 - c1) * i / N;
      if (alt(t).altGeo > -0.8333) { if (visibleFrom === null) visibleFrom = t; visibleTo = t; }
    }
    return {
      local,
      c1: new Date(c1), c2: c2 && new Date(c2), max: new Date(tMax), c3: c3 && new Date(c3), c4: new Date(c4),
      magnitude: (sMax.rS + sMax.rMp - sMax.sep) / (2 * sMax.rS),
      obscuration: overlapArea(sMax.rS, sMax.rMp, sMax.sep),
      sunAltMax: pMax.alt, sunAzMax: pMax.az,
      sunAltC1: alt(c1).alt, sunAltC4: alt(c4).alt,
      visible: visibleFrom !== null,
      risesEclipsed: visibleFrom !== null && visibleFrom > c1 + 1000,
      setsEclipsed: visibleTo !== null && visibleTo < c4 - 1000
    };
  }

  /** Upcoming solar eclipses visible (at least partly, Sun above horizon) from obs. */
  function upcomingEclipses(from, obs, count, maxYears) {
    const out = [];
    const end = from.getTime() + (maxYears || 25) * 365.25 * 86400000;
    let t = from.getTime() - 6 * 3600000;
    while (out.length < count && t < end) {
      const nm = newMoonAfter(t);
      t = nm + 20 * 86400000;
      const jd = jdFromDate(new Date(nm)), T = (jd + deltaT(jd) / 86400 - 2451545) / 36525;
      if (Math.abs(moonEcl(T, nutation(T)).beta) > 1.6) continue;
      const loc = localEclipse(nm, obs);
      if (!loc || !loc.visible || loc.c4 < from) continue;
      const g = globalKind(nm);
      out.push(Object.assign({ global: g.kind, gamma: g.gamma }, loc));
    }
    return out;
  }

  /** Apparent offset of the Moon from the Sun (degrees, in the local horizontal frame) and disk radii (degrees). */
  function sunMoonDisks(date, obs) {
    const s = diskState(date.getTime(), obs);
    const hs = horizontal(s.c.sun, s.c.lst, obs.lat), hm = horizontal(s.c.moon, s.c.lst, obs.lat);
    return { sun: hs, moon: hm, rS: s.rS * R2D, rM: s.rMp * R2D, sep: s.sep * R2D };
  }

  // ---------- Magnetic declination (IGRF-13, epoch 2020, degree 4) ----------
  // [n, m, g, h, dg, dh] in nT and nT/yr
  const IGRF = [
    [1,0,-29404.8,0,5.7,0],[1,1,-1450.9,4652.5,7.4,-25.9],
    [2,0,-2499.6,0,-11.0,0],[2,1,2982.0,-2991.6,-7.0,-30.2],[2,2,1677.0,-734.6,-2.1,-22.4],
    [3,0,1363.2,0,2.2,0],[3,1,-2381.2,-82.1,-5.9,6.0],[3,2,1236.2,241.9,3.1,-1.1],[3,3,525.7,-543.4,-12.0,0.5],
    [4,0,903.0,0,-1.2,0],[4,1,809.5,281.9,-1.6,-0.1],[4,2,86.3,-158.4,-5.9,6.5],[4,3,-309.4,199.7,5.2,3.6],[4,4,48.0,-349.7,-5.1,-5.0]
  ];
  function schmidtP(n, m, x, s) { // Schmidt semi-normalised associated Legendre functions, n ≤ 4
    switch (n * 10 + m) {
      case 10: return x; case 11: return s;
      case 20: return (3 * x * x - 1) / 2; case 21: return Math.sqrt(3) * x * s; case 22: return Math.sqrt(3) / 2 * s * s;
      case 30: return (5 * x * x * x - 3 * x) / 2; case 31: return Math.sqrt(6) / 4 * s * (5 * x * x - 1);
      case 32: return Math.sqrt(15) / 2 * x * s * s; case 33: return Math.sqrt(10) / 4 * s * s * s;
      case 40: return (35 * x ** 4 - 30 * x * x + 3) / 8; case 41: return Math.sqrt(10) / 4 * s * (7 * x ** 3 - 3 * x);
      case 42: return Math.sqrt(5) / 4 * s * s * (7 * x * x - 1); case 43: return Math.sqrt(70) / 4 * x * s ** 3;
      case 44: return Math.sqrt(35) / 8 * s ** 4;
    }
    return 0;
  }
  /** Magnetic declination in degrees (east positive). */
  function magneticDeclination(lat, lon, date) {
    const yrs = Math.max(-5, Math.min(10, (date.getTime() - Date.UTC(2020, 0, 1)) / (365.25 * 86400000)));
    const latGc = Math.atan(0.99330562 * tand(lat)) * R2D;
    const S = (theta, phi) => {
      const x = Math.cos(theta), s = Math.sin(theta);
      let v = 0;
      for (const [n, m, g, h, dg, dh] of IGRF) {
        const gg = g + dg * yrs, hh = h + dh * yrs;
        v += (gg * Math.cos(m * phi) + hh * Math.sin(m * phi)) * schmidtP(n, m, x, s);
      }
      return v;
    };
    const th = (90 - latGc) * D2R, ph = lon * D2R, e = 1e-5;
    const X = (S(th + e, ph) - S(th - e, ph)) / (2 * e);
    const Y = -(S(th, ph + e) - S(th, ph - e)) / (2 * e) / Math.max(1e-6, Math.sin(th));
    return Math.atan2(Y, X) * R2D;
  }

  const api = {
    sunPosition, moonPosition, sunEvents, moonEvents, moonPhase, seasons, upcomingEclipses, sunMoonDisks, magneticDeclination,
    _internal: { moonEcl, sunEcl, nutation, jdFromDate, dateFromJd, deltaT, newMoonAfter, localEclipse, globalKind }
  };
  root.Astro = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof self !== "undefined" ? self : this);
