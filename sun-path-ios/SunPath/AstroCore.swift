import Foundation

/// Astronomy, all on-device (ported 1:1 from the web version, which was validated against
/// Meeus' worked examples, equinox/solstice times and NASA eclipse contacts).
///  - Sun: truncated VSOP87 (Meeus ch. 25 / App. III), ~1 arcsecond
///  - Moon: Meeus ch. 47 (truncated ELP-2000/82)
///  - Eclipses: topocentric disk overlap searched at each new moon
///  - Magnetic declination: IGRF-13 to degree 4 (only used if true north is unavailable)
/// Times are seconds since 1970 (Date.timeIntervalSince1970).
enum Astro {
    static let D2R = Double.pi / 180
    static let R2D = 180 / Double.pi
    static func sind(_ x: Double) -> Double { sin(x * D2R) }
    static func cosd(_ x: Double) -> Double { cos(x * D2R) }
    static func tand(_ x: Double) -> Double { tan(x * D2R) }
    static func norm360(_ x: Double) -> Double {
        var y = x.truncatingRemainder(dividingBy: 360)
        if y < 0 { y += 360 }
        return y
    }
    static func wrap180(_ x: Double) -> Double {
        let y = norm360(x)
        return y > 180 ? y - 360 : y
    }

    static let AU_KM = 149597870.7
    static let EARTH_R = 6378.137
    static let SUN_R = 696000.0
    static let MOON_R_PEN = 1737.4 * 1.00042
    static let MOON_R_UMB = 1736.0

    struct Observer { var lat: Double; var lon: Double; var h: Double }
    struct Horizontal { var az: Double; var alt: Double; var ra: Double; var dec: Double; var dist: Double }
    struct SunPos { var az: Double; var alt: Double; var altGeo: Double; var distKm: Double }
    struct Nut { var dpsi: Double; var eps: Double }
    struct Ecl { var lam: Double; var beta: Double; var distKm: Double; var R: Double }
    struct Ctx {
        var jdUT: Double
        var lst: Double
        var sun: SIMD3<Double>
        var sunGeo: SIMD3<Double>
        var moon: SIMD3<Double>
        var moonGeo: SIMD3<Double>
    }

    static func jdT(_ t: Double) -> Double { t / 86400 + 2440587.5 }
    static func len(_ v: SIMD3<Double>) -> Double { (v.x * v.x + v.y * v.y + v.z * v.z).squareRoot() }

    static func deltaT(_ jd: Double) -> Double {
        let y = 2000 + (jd - 2451544.5) / 365.25
        if y > 1990 && y < 2150 { let u = y - 2026; return 69.2 + 0.3 * u + 0.005 * u * u }
        let u = (y - 1820) / 100
        return -20 + 32 * u * u
    }

    static func centuries(_ t: Double) -> Double {
        let jd = jdT(t)
        return (jd + deltaT(jd) / 86400 - 2451545) / 36525
    }

    static func nutation(_ T: Double) -> Nut {
        let om = 125.04452 - 1934.136261 * T, L = 280.4665 + 36000.7698 * T, Lp = 218.3165 + 481267.8813 * T
        let dpsi = (-17.20 * sind(om) - 1.32 * sind(2 * L) - 0.23 * sind(2 * Lp) + 0.21 * sind(2 * om)) / 3600
        let deps = (9.20 * cosd(om) + 0.57 * cosd(2 * L) + 0.10 * cosd(2 * Lp) - 0.09 * cosd(2 * om)) / 3600
        let eps0 = 23.43929111 - 0.0130041667 * T - 1.6389e-7 * T * T + 5.0361e-7 * T * T * T
        return Nut(dpsi: dpsi, eps: eps0 + deps)
    }

    static func vsop(_ series: [[Double]], _ tau: Double) -> Double {
        var sum = 0.0, tp = 1.0
        for terms in series {
            var s = 0.0
            var i = 0
            while i + 2 < terms.count {
                s += terms[i] * cos(terms[i + 1] + terms[i + 2] * tau)
                i += 3
            }
            sum += s * tp
            tp *= tau
        }
        return sum / 1e8
    }

    static func sunEcl(_ T: Double, _ n: Nut) -> Ecl {
        let tau = T / 10
        let L = vsop(VL, tau) * R2D, B = vsop(VB, tau) * R2D, R = vsop(VR, tau)
        var lam = L + 180, beta = -B
        let lp = lam - 1.397 * T - 0.00031 * T * T
        lam += (-0.09033 + 0.03916 * (cosd(lp) + sind(lp)) * tand(beta)) / 3600
        beta += 0.03916 * (cosd(lp) - sind(lp)) / 3600
        lam += n.dpsi - 20.4898 / 3600 / R
        return Ecl(lam: norm360(lam), beta: beta, distKm: R * AU_KM, R: R)
    }

    static func moonEcl(_ T: Double, _ n: Nut) -> Ecl {
        let T2 = T * T, T3 = T2 * T, T4 = T3 * T
        let Lp = norm360(218.3164477 + 481267.88123421 * T - 0.0015786 * T2 + T3 / 538841 - T4 / 65194000)
        let D = norm360(297.8501921 + 445267.1114034 * T - 0.0018819 * T2 + T3 / 545868 - T4 / 113065000)
        let M = norm360(357.5291092 + 35999.0502909 * T - 0.0001536 * T2 + T3 / 24490000)
        let Mp = norm360(134.9633964 + 477198.8675055 * T + 0.0087414 * T2 + T3 / 69699 - T4 / 14712000)
        let F = norm360(93.2720950 + 483202.0175233 * T - 0.0036539 * T2 - T3 / 3526000 + T4 / 863310000)
        let A1 = 119.75 + 131.849 * T, A2 = 53.09 + 479264.290 * T, A3 = 313.45 + 481266.484 * T
        let E = 1 - 0.002516 * T - 0.0000074 * T2, E2 = E * E
        var sl = 0.0, sr = 0.0, sb = 0.0
        var i = 0
        while i + 5 < MOON_LR.count {
            let m = MOON_LR[i + 1]
            let arg = MOON_LR[i] * D + m * M + MOON_LR[i + 2] * Mp + MOON_LR[i + 3] * F
            let ef = m == 0 ? 1 : (abs(m) == 1 ? E : E2)
            sl += MOON_LR[i + 4] * ef * sind(arg)
            sr += MOON_LR[i + 5] * ef * cosd(arg)
            i += 6
        }
        i = 0
        while i + 4 < MOON_B.count {
            let m = MOON_B[i + 1]
            let arg = MOON_B[i] * D + m * M + MOON_B[i + 2] * Mp + MOON_B[i + 3] * F
            let ef = m == 0 ? 1 : (abs(m) == 1 ? E : E2)
            sb += MOON_B[i + 4] * ef * sind(arg)
            i += 5
        }
        sl += 3958 * sind(A1) + 1962 * sind(Lp - F) + 318 * sind(A2)
        sb += -2235 * sind(Lp) + 382 * sind(A3) + 175 * sind(A1 - F) + 175 * sind(A1 + F) + 127 * sind(Lp - Mp) - 115 * sind(Lp + Mp)
        return Ecl(lam: norm360(Lp + sl / 1e6 + n.dpsi), beta: sb / 1e6, distKm: 385000.56 + sr / 1000, R: 0)
    }

    static func eclToEqVec(_ lam: Double, _ beta: Double, _ eps: Double, _ dist: Double) -> SIMD3<Double> {
        let cb = cosd(beta)
        let x = cb * cosd(lam), y = cb * sind(lam), z = sind(beta)
        return SIMD3<Double>(dist * x, dist * (y * cosd(eps) - z * sind(eps)), dist * (y * sind(eps) + z * cosd(eps)))
    }

    static func gast(_ jdUT: Double, _ n: Nut) -> Double {
        let d = jdUT - 2451545.0, T = d / 36525
        let gmst = 280.46061837 + 360.98564736629 * d + 0.000387933 * T * T - T * T * T / 38710000
        return norm360(gmst + n.dpsi * cosd(n.eps))
    }

    static func observerVec(_ lat: Double, _ lon: Double, _ hM: Double, _ lst: Double) -> SIMD3<Double> {
        let u = atan(0.99664719 * tand(lat))
        let rs = 0.99664719 * sin(u) + (hM / 6378140) * sind(lat)
        let rc = cos(u) + (hM / 6378140) * cosd(lat)
        return SIMD3<Double>(EARTH_R * rc * cosd(lst), EARTH_R * rc * sind(lst), EARTH_R * rs)
    }

    /// Degrees to add to a geometric altitude (standard atmosphere).
    static func refraction(_ h: Double) -> Double {
        if h < -1.5 { return 0 }
        let hh = max(h, -1.0)
        return 1.02 / tand(hh + 10.3 / (hh + 5.11)) / 60
    }

    static func context(_ t: Double, _ obs: Observer, _ withMoon: Bool) -> Ctx {
        let jdUT = jdT(t), jde = jdUT + deltaT(jdUT) / 86400, T = (jde - 2451545) / 36525
        let n = nutation(T)
        let s = sunEcl(T, n)
        let lst = norm360(gast(jdUT, n) + obs.lon)
        let o = observerVec(obs.lat, obs.lon, obs.h, lst)
        let sv = eclToEqVec(s.lam, s.beta, n.eps, s.distKm)
        var mv = SIMD3<Double>(0, 0, 0)
        if withMoon {
            let m = moonEcl(T, n)
            mv = eclToEqVec(m.lam, m.beta, n.eps, m.distKm)
        }
        return Ctx(jdUT: jdUT, lst: lst, sun: sv - o, sunGeo: sv, moon: mv - o, moonGeo: mv)
    }

    static func horizontal(_ v: SIMD3<Double>, _ lst: Double, _ lat: Double) -> Horizontal {
        let r = len(v)
        let ra = atan2(v.y, v.x) * R2D, dec = asin(v.z / r) * R2D
        let H = lst - ra
        let alt = asin(sind(lat) * sind(dec) + cosd(lat) * cosd(dec) * cosd(H)) * R2D
        let az = norm360(atan2(sind(H), cosd(H) * sind(lat) - tand(dec) * cosd(lat)) * R2D + 180)
        return Horizontal(az: az, alt: alt, ra: norm360(ra), dec: dec, dist: r)
    }

    /// Sun position; `alt` is apparent (refracted), `altGeo` geometric.
    static func sunPosition(_ t: Double, _ obs: Observer) -> SunPos {
        let c = context(t, obs, false)
        let h = horizontal(c.sun, c.lst, obs.lat)
        return SunPos(az: h.az, alt: h.alt + refraction(h.alt), altGeo: h.alt, distKm: h.dist)
    }
    static func sunPosition(_ d: Date, _ obs: Observer) -> SunPos { sunPosition(d.timeIntervalSince1970, obs) }

    static func bisect(_ f: (Double) -> Double, _ a0: Double, _ b0: Double, _ fa0: Double, _ tol: Double) -> Double {
        var a = a0, b = b0, fa = fa0
        var i = 0
        while i < 60 && b - a > tol {
            let m = (a + b) / 2, fm = f(m)
            if (fm > 0) == (fa > 0) { a = m; fa = fm } else { b = m }
            i += 1
        }
        return (a + b) / 2
    }

    static func goldenMin(_ f: (Double) -> Double, _ a0: Double, _ b0: Double, _ tol: Double) -> Double {
        let g = 0.6180339887
        var a = a0, b = b0
        var c = b - g * (b - a), d = a + g * (b - a)
        var fc = f(c), fd = f(d)
        while b - a > tol {
            if fc < fd { b = d; d = c; fd = fc; c = b - g * (b - a); fc = f(c) }
            else { a = c; c = d; fc = fd; d = a + g * (b - a); fd = f(d) }
        }
        return (a + b) / 2
    }

    struct SunEvents {
        var rise: Date?
        var set: Date?
        var noon: Date
        var noonAlt: Double
        var state: String      // "normal", "polarDay", "polarNight"
        var dayLength: Double  // seconds
    }

    /// Rise, set and highest point for the local day starting at `t0`.
    /// `f` = altitude above the rise/set threshold, `apparent` = altitude to report at the highest point.
    private static func dayEvents(_ t0: Double, _ f: (Double) -> Double, _ apparent: (Double) -> Double) -> SunEvents {
        var rise: Double? = nil, set: Double? = nil
        var prev = f(t0)
        let step = 600.0
        var t = t0 + step
        while t <= t0 + 86400 {
            let cur = f(t)
            if prev < 0 && cur >= 0 && rise == nil { rise = bisect(f, t - step, t, prev, 1) }
            if prev >= 0 && cur < 0 && set == nil { set = bisect(f, t - step, t, prev, 1) }
            prev = cur
            t += step
        }
        var best = t0, bestAlt = -99.0
        t = t0
        while t <= t0 + 86400 { let a = f(t); if a > bestAlt { bestAlt = a; best = t }; t += 1800 }
        let noonT = goldenMin({ -f($0) }, best - 1800, best + 1800, 1)
        var state = "normal"
        if rise == nil && set == nil { state = f(noonT) > 0 ? "polarDay" : "polarNight" }
        var dl = 0.0
        if let r = rise, let s = set { dl = s > r ? s - r : 86400 - (r - s) } else if state == "polarDay" { dl = 86400 }
        return SunEvents(rise: rise.map { Date(timeIntervalSince1970: $0) }, set: set.map { Date(timeIntervalSince1970: $0) },
                         noon: Date(timeIntervalSince1970: noonT), noonAlt: apparent(noonT), state: state, dayLength: dl)
    }

    /// Sunrise, sunset and solar noon for the local day starting at `dayStart`.
    static func sunEvents(_ dayStart: Date, _ obs: Observer) -> SunEvents {
        dayEvents(dayStart.timeIntervalSince1970, { sunPosition($0, obs).altGeo + 0.8333 }, { sunPosition($0, obs).alt })
    }

    /// Moonrise, moonset and the Moon's highest point for the local day starting at `dayStart`.
    /// Rise/set = upper limb on the horizon (34' refraction + topocentric semi-diameter).
    static func moonEvents(_ dayStart: Date, _ obs: Observer) -> SunEvents {
        dayEvents(dayStart.timeIntervalSince1970, { t in
            let p = moonPosition(t, obs)
            return p.altGeo + 0.5667 + asin(1737.4 / p.distKm) * R2D
        }, { moonPosition($0, obs).alt })
    }

    /// Topocentric Moon; `alt` is apparent (refracted).
    static func moonPosition(_ t: Double, _ obs: Observer) -> SunPos {
        let c = context(t, obs, true)
        let h = horizontal(c.moon, c.lst, obs.lat)
        return SunPos(az: h.az, alt: h.alt + refraction(h.alt), altGeo: h.alt, distKm: h.dist)
    }
    static func moonPosition(_ d: Date, _ obs: Observer) -> SunPos { moonPosition(d.timeIntervalSince1970, obs) }

    struct MoonPhase {
        var illum: Double     // illuminated fraction 0…1
        var waxing: Bool
        var index: Int        // 0 new, 1 waxing crescent, 2 first quarter, 3 waxing gibbous, 4 full, 5 waning gibbous, 6 last quarter, 7 waning crescent
    }
    /// Moon phase (Meeus ch. 48: phase angle from elongation and distances).
    static func moonPhase(_ d: Date) -> MoonPhase {
        let T = centuries(d.timeIntervalSince1970), n = nutation(T)
        let s = sunEcl(T, n), m = moonEcl(T, n)
        let sv = eclToEqVec(s.lam, s.beta, n.eps, s.distKm), mv = eclToEqVec(m.lam, m.beta, n.eps, m.distKm)
        let psi = vAngle(sv, mv)
        let i = atan2(len(sv) * sin(psi), len(mv) - len(sv) * cos(psi))
        let dl = norm360(m.lam - s.lam)
        return MoonPhase(illum: (1 + cos(i)) / 2, waxing: dl < 180, index: Int((dl / 45).rounded()) % 8)
    }

    static func sunLongitudeTime(_ target: Double, _ guess: Double) -> Double {
        var t = guess
        for _ in 0..<8 {
            let T = centuries(t)
            let lam = sunEcl(T, nutation(T)).lam
            let diff = wrap180(target - lam)
            t += diff / 0.98564736 * 86400
            if abs(diff) < 1e-6 { break }
        }
        return t
    }

    /// March equinox, June solstice, September equinox, December solstice.
    static func seasons(_ year: Int) -> [Date] {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
        func g(_ m: Int, _ d: Int) -> Double {
            (cal.date(from: DateComponents(year: year, month: m, day: d)) ?? Date()).timeIntervalSince1970
        }
        return [sunLongitudeTime(0, g(3, 20)), sunLongitudeTime(90, g(6, 21)),
                sunLongitudeTime(180, g(9, 22)), sunLongitudeTime(270, g(12, 21))].map { Date(timeIntervalSince1970: $0) }
    }

    // MARK: - Solar eclipses

    struct Eclipse: Identifiable {
        var id: Double
        var global: String   // total / annular / partial
        var local: String    // total / annular / partial (as seen here)
        var c1: Date
        var c2: Date?
        var max: Date
        var c3: Date?
        var c4: Date
        var magnitude: Double
        var obscuration: Double
        var sunAltMax: Double
        var risesEclipsed: Bool
        var setsEclipsed: Bool
    }

    static func vAngle(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
        let dot = a.x * b.x + a.y * b.y + a.z * b.z
        let cx = a.y * b.z - a.z * b.y, cy = a.z * b.x - a.x * b.z, cz = a.x * b.y - a.y * b.x
        return atan2((cx * cx + cy * cy + cz * cz).squareRoot(), dot)
    }

    struct Disk { var c: Ctx; var sep: Double; var rS: Double; var rMp: Double; var rMu: Double }
    static func diskState(_ t: Double, _ obs: Observer) -> Disk {
        let c = context(t, obs, true)
        let ds = len(c.sun), dm = len(c.moon)
        return Disk(c: c, sep: vAngle(c.sun, c.moon), rS: asin(SUN_R / ds), rMp: asin(MOON_R_PEN / dm), rMu: asin(MOON_R_UMB / dm))
    }

    static func newMoonAfter(_ t0: Double) -> Double {
        func elong(_ tt: Double) -> Double {
            let T = centuries(tt), n = nutation(T)
            return wrap180(moonEcl(T, n).lam - sunEcl(T, n).lam)
        }
        var t = t0
        var e = elong(t)
        let adv = norm360(-e)
        t += (adv == 0 ? 360 : adv) / 12.19 * 86400
        for _ in 0..<6 {
            e = elong(t)
            t -= e / 12.19 * 86400
            if abs(e) < 1e-5 { break }
        }
        return t
    }

    static func overlapArea(_ rS: Double, _ rM: Double, _ d: Double) -> Double {
        if d >= rS + rM { return 0 }
        if d <= abs(rM - rS) { return rM >= rS ? 1 : (rM * rM) / (rS * rS) }
        let a = rS * rS * acos((d * d + rS * rS - rM * rM) / (2 * d * rS))
        let b = rM * rM * acos((d * d + rM * rM - rS * rS) / (2 * d * rM))
        let c = 0.5 * ((-d + rS + rM) * (d + rS - rM) * (d - rS + rM) * (d + rS + rM)).squareRoot()
        return (a + b - c) / (Double.pi * rS * rS)
    }

    static func globalKind(_ tNM: Double) -> String {
        let geo = Observer(lat: 0, lon: 0, h: 0)
        func axis(_ t: Double) -> (gamma: Double, along: Double, sunMoon: Double) {
            let c = context(t, geo, true)
            let S = c.sunGeo, M = c.moonGeo
            var u = M - S
            let ul = len(u)
            u = u / ul
            let along = -(M.x * u.x + M.y * u.y + M.z * u.z)
            let p = M + along * u
            return (len(p) / EARTH_R, along, ul)
        }
        let tm = goldenMin({ axis($0).gamma }, tNM - 4 * 3600, tNM + 4 * 3600, 5)
        let a = axis(tm)
        let umbraLen = a.sunMoon * MOON_R_UMB / (SUN_R - MOON_R_UMB)
        let reach = a.along - EARTH_R * max(0, 1 - a.gamma * a.gamma).squareRoot()
        if a.gamma < 0.9972 { return umbraLen > reach ? "total" : "annular" }
        return "partial"
    }

    static func localEclipse(_ tNM: Double, _ obs: Observer) -> Eclipse? {
        let f: (Double) -> Double = { t in let s = diskState(t, obs); return s.sep - s.rS - s.rMp }
        let W = 5.0 * 3600
        var best = tNM, bestV = Double.infinity
        var t = tNM - W
        while t <= tNM + W { let v = f(t); if v < bestV { bestV = v; best = t }; t += 120 }
        if bestV >= 0 { return nil }
        let tMax = goldenMin({ diskState($0, obs).sep }, best - 240, best + 240, 0.5)
        let sMax = diskState(tMax, obs)
        let c1 = bisect(f, tMax - W, tMax, f(tMax - W), 0.5)
        let c4 = bisect(f, tMax, tMax + W, sMax.sep - sMax.rS - sMax.rMp, 0.5)
        var c2: Double? = nil, c3: Double? = nil
        let g: (Double) -> Double = { t in let s = diskState(t, obs); return s.sep - abs(s.rMu - s.rS) }
        let gMax = g(tMax)
        if gMax < 0 {
            c2 = bisect(g, tMax - 600, tMax, g(tMax - 600), 0.2)
            c3 = bisect(g, tMax, tMax + 600, gMax, 0.2)
        }
        var vFrom: Double? = nil, vTo: Double? = nil
        for i in 0...60 {
            let tt = c1 + (c4 - c1) * Double(i) / 60
            if sunPosition(tt, obs).altGeo > -0.8333 { if vFrom == nil { vFrom = tt }; vTo = tt }
        }
        guard let vf = vFrom, let vt = vTo else { return nil }
        let local = c2 != nil ? (sMax.rMu > sMax.rS ? "total" : "annular") : "partial"
        return Eclipse(id: tMax, global: "partial", local: local,
                       c1: Date(timeIntervalSince1970: c1), c2: c2.map { Date(timeIntervalSince1970: $0) },
                       max: Date(timeIntervalSince1970: tMax), c3: c3.map { Date(timeIntervalSince1970: $0) },
                       c4: Date(timeIntervalSince1970: c4),
                       magnitude: (sMax.rS + sMax.rMp - sMax.sep) / (2 * sMax.rS),
                       obscuration: overlapArea(sMax.rS, sMax.rMp, sMax.sep),
                       sunAltMax: sunPosition(tMax, obs).alt,
                       risesEclipsed: vf > c1 + 1, setsEclipsed: vt < c4 - 1)
    }

    /// Upcoming solar eclipses with the Sun above the horizon at some point from `obs`.
    static func upcomingEclipses(from: Date, obs: Observer, count: Int, maxYears: Double) -> [Eclipse] {
        var out: [Eclipse] = []
        let end = from.timeIntervalSince1970 + maxYears * 365.25 * 86400
        var t = from.timeIntervalSince1970 - 6 * 3600
        while out.count < count && t < end {
            let nm = newMoonAfter(t)
            t = nm + 20 * 86400
            let T = centuries(nm)
            if abs(moonEcl(T, nutation(T)).beta) > 1.6 { continue }
            guard var e = localEclipse(nm, obs), e.c4 >= from else { continue }
            e.global = globalKind(nm)
            out.append(e)
        }
        return out
    }

    struct Disks { var sun: Horizontal; var moon: Horizontal; var rS: Double; var rM: Double }
    /// Sun and Moon as seen from obs (degrees).
    static func sunMoonDisks(_ d: Date, _ obs: Observer) -> Disks {
        let s = diskState(d.timeIntervalSince1970, obs)
        return Disks(sun: horizontal(s.c.sun, s.c.lst, obs.lat), moon: horizontal(s.c.moon, s.c.lst, obs.lat),
                     rS: s.rS * R2D, rM: s.rMp * R2D)
    }

    // MARK: - Magnetic declination (IGRF-13 epoch 2020, degree 4)

    static func schmidtP(_ n: Int, _ m: Int, _ x: Double, _ s: Double) -> Double {
        switch n * 10 + m {
        case 10: return x
        case 11: return s
        case 20: return (3 * x * x - 1) / 2
        case 21: return 3.0.squareRoot() * x * s
        case 22: return 3.0.squareRoot() / 2 * s * s
        case 30: return (5 * x * x * x - 3 * x) / 2
        case 31: return 6.0.squareRoot() / 4 * s * (5 * x * x - 1)
        case 32: return 15.0.squareRoot() / 2 * x * s * s
        case 33: return 10.0.squareRoot() / 4 * s * s * s
        case 40: return (35 * x * x * x * x - 30 * x * x + 3) / 8
        case 41: return 10.0.squareRoot() / 4 * s * (7 * x * x * x - 3 * x)
        case 42: return 5.0.squareRoot() / 4 * s * s * (7 * x * x - 1)
        case 43: return 70.0.squareRoot() / 4 * x * s * s * s
        case 44: return 35.0.squareRoot() / 8 * s * s * s * s
        default: return 0
        }
    }

    /// Magnetic declination in degrees, east positive.
    static func magneticDeclination(_ lat: Double, _ lon: Double, _ date: Date) -> Double {
        let ref = 1577836800.0 // 2020-01-01
        let yrs = max(-5, min(10, (date.timeIntervalSince1970 - ref) / (365.25 * 86400)))
        let latGc = atan(0.99330562 * tand(lat)) * R2D
        func S(_ theta: Double, _ phi: Double) -> Double {
            let x = cos(theta), s = sin(theta)
            var v = 0.0
            var i = 0
            while i + 5 < IGRF.count {
                let n = Int(IGRF[i]), m = Int(IGRF[i + 1])
                let gg = IGRF[i + 2] + IGRF[i + 4] * yrs, hh = IGRF[i + 3] + IGRF[i + 5] * yrs
                v += (gg * cos(Double(m) * phi) + hh * sin(Double(m) * phi)) * schmidtP(n, m, x, s)
                i += 6
            }
            return v
        }
        let th = (90 - latGc) * D2R, ph = lon * D2R, e = 1e-5
        let X = (S(th + e, ph) - S(th - e, ph)) / (2 * e)
        let Y = -(S(th, ph + e) - S(th, ph - e)) / (2 * e) / max(1e-6, sin(th))
        return atan2(Y, X) * R2D
    }
}
