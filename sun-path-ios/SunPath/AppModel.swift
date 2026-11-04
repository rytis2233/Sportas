import SwiftUI
import UIKit
import CoreLocation

enum Panel { case travel, compare, calibrate }
enum SkyBody: String { case sun, moon }
enum SheetKind: String, Identifiable { case about, eclipses, language; var id: String { rawValue } }

struct Loc: Codable, Equatable { var lat: Double; var lon: Double; var h: Double; var src: String }
struct Cal: Codable, Equatable { var yaw = 0.0; var pitch = 0.0; var fovAdj = 0.0; var auto = true }
struct SkyPt { var az: Double; var alt: Double }
struct HourPt { var h: Int; var az: Double; var alt: Double }
struct RiseSet { var t: Date; var rise: Bool; var az: Double }
struct DayPath { var pts: [SkyPt]; var hours: [HourPt]; var ev: Astro.SunEvents; var rs: [RiseSet]; var apex: SkyPt }

struct HudInfo { var dir: String; var deg: String; var readout: String; var chip: String?; var alert: Bool }

/// Maps sky directions to screen points for the current camera orientation.
struct Projector {
    let cam: [Double]  // world ← camera
    let f: Double      // focal length in points
    let w: Double
    let h: Double
    func project(_ az: Double, _ alt: Double) -> CGPoint? {
        let d = M3.applyT(cam, M3.worldVec(az, alt))
        if d[2] > -0.05 { return nil }
        return CGPoint(x: w / 2 + f * d[0] / -d[2], y: h / 2 - f * d[1] / -d[2])
    }
    func direction(at p: CGPoint) -> (az: Double, alt: Double) {
        let dx = (Double(p.x) - w / 2) / f, dy = -(Double(p.y) - h / 2) / f
        let n = (dx * dx + dy * dy + 1).squareRoot()
        let v = M3.apply(cam, [dx / n, dy / n, -1 / n])
        return (M3.headingOf(v), asin(max(-1, min(1, v[2]))) * Astro.R2D)
    }
}

final class AppModel: ObservableObject {
    let motion = MotionService()
    let camera = CameraService()
    let locSvc = LocationService()
    private let ud = UserDefaults.standard

    @Published var lang: String { didSet { L.lang = lang; ud.set(lang, forKey: "lang") } }
    @Published var loc: Loc { didSet { locationChanged() } }
    @Published var cal: Cal { didSet { if let d = try? JSONEncoder().encode(cal) { ud.set(d, forKey: "cal") } } }
    @Published var solstice: Bool { didSet { ud.set(solstice, forKey: "solstice") } }
    /// Which body the overlay tracks.
    @Published var target: SkyBody { didSet { ud.set(target.rawValue, forKey: "target") } }
    @Published var travel: Date? = nil
    @Published var compare: Date? = nil
    @Published var eclipse: Astro.Eclipse? = nil
    @Published var playing = false { didSet { updatePlayTimer() } }
    @Published var panel: Panel? = nil
    @Published var sheet: SheetKind? = nil
    @Published var menuOpen = false
    @Published var toast: String? = nil
    @Published var cameraOn = false
    @Published var eclipses: [Astro.Eclipse]? = nil

    var screen = CGSize(width: 390, height: 844)
    var lookYaw = 160.0, lookPitch = 15.0       // look-around without motion sensors
    private var pathCache: [String: DayPath] = [:]
    private var seasonCache: [Int: [Date]] = [:]
    private var playTimer: Timer?
    private var toastWork: DispatchWorkItem?
    private var detPrevAz = 0.0, detPrevAlt = 0.0, detCount = 0, detAligned = false, detAnnounced = false
    private var started = false
    private var motionStarted = false

    init() {
        let defaults = UserDefaults.standard
        let sysLT = (Locale.preferredLanguages.first ?? "en").hasPrefix("lt")
        let l = defaults.string(forKey: "lang") ?? (sysLT ? "lt" : "en")
        lang = l
        L.lang = l
        if let d = defaults.data(forKey: "loc"), let v = try? JSONDecoder().decode(Loc.self, from: d) { loc = v }
        else { loc = Loc(lat: 50, lon: max(-180, min(180, Double(TimeZone.current.secondsFromGMT()) / 240)), h: 0, src: "approx") }
        if let d = defaults.data(forKey: "cal"), let v = try? JSONDecoder().decode(Cal.self, from: d) { cal = v } else { cal = Cal() }
        solstice = defaults.bool(forKey: "solstice")
        target = SkyBody(rawValue: defaults.string(forKey: "target") ?? "sun") ?? .sun
        motion.magneticDecl = Astro.magneticDeclination(loc.lat, loc.lon, Date())
        camera.onSun = { [weak self] p in self?.handleSun(p) }
        locSvc.onLocation = { [weak self] l in self?.gotLocation(l) }
        locSvc.onAuthorization = { [weak self] ok in
            guard let self = self else { return }
            self.startMotion()
            if !ok && self.loc.src == "approx" { self.showToast(L.t("noLoc")) }
        }
    }

    var obs: Astro.Observer { Astro.Observer(lat: loc.lat, lon: loc.lon, h: loc.h) }
    func position(_ d: Date, _ b: SkyBody) -> Astro.SunPos {
        b == .sun ? Astro.sunPosition(d, obs) : Astro.moonPosition(d, obs)
    }
    func now() -> Date { travel ?? Date() }

    // MARK: start-up

    func start() {
        guard !started else { return }
        started = true
        locSvc.start()
        // true north needs location; start motion when location is authorised, or after a few seconds anyway
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in self?.startMotion() }
        camera.start { [weak self] ok in
            self?.cameraOn = ok
            if !ok { self?.showToast(L.t("noCam")) }
        }
    }

    private func startMotion() {
        guard !motionStarted else { return }
        motionStarted = true
        motion.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.motion.fallbackIfSilent() }
    }

    private func gotLocation(_ l: CLLocation) {
        if loc.src == "manual" { return }
        let c = l.coordinate
        if loc.src != "gps" || abs(loc.lat - c.latitude) > 0.002 || abs(loc.lon - c.longitude) > 0.002 {
            loc = Loc(lat: c.latitude, lon: c.longitude, h: l.altitude, src: "gps")
        }
    }

    func useGPS() {
        loc = Loc(lat: loc.lat, lon: loc.lon, h: loc.h, src: "approx")
        locSvc.requestOnce()
    }

    private func locationChanged() {
        if let d = try? JSONEncoder().encode(loc) { ud.set(d, forKey: "loc") }
        motion.magneticDecl = Astro.magneticDeclination(loc.lat, loc.lon, Date())
        pathCache.removeAll()
        seasonCache.removeAll()
        eclipses = nil
    }

    // MARK: projection

    func cameraMatrix() -> [Double] {
        if let R = motion.R {
            return M3.mul(M3.mul(M3.Rz(-cal.yaw), R), M3.Rx(cal.pitch))
        }
        return M3.mul(M3.Rz(-lookYaw), M3.Rx(90 + lookPitch))
    }

    var effectiveFov: Double { (camera.fov > 10 ? camera.fov : 64) + cal.fovAdj }

    func projector(_ size: CGSize) -> Projector {
        let bw = camera.bufferW, bh = camera.bufferH
        let s = max(Double(size.width) / bw, Double(size.height) / bh)   // aspect-fill
        let f = (max(bw, bh) * s / 2) / tan(effectiveFov / 2 * Astro.D2R)
        return Projector(cam: cameraMatrix(), f: f, w: Double(size.width), h: Double(size.height))
    }

    static func cameraDirection(_ R: [Double]) -> (az: Double, alt: Double) {
        let fwd = M3.apply(R, [0, 0, -1]), up = M3.apply(R, [0, 1, 0])
        let az = hypot(fwd[0], fwd[1]) > 0.15 ? M3.headingOf(fwd) : M3.headingOf(fwd[2] < 0 ? up : up.map { -$0 })
        return (az, asin(max(-1, min(1, fwd[2]))) * Astro.R2D)
    }

    // MARK: sun paths

    func dayPath(_ date: Date, _ b: SkyBody = .sun) -> DayPath {
        let calr = Calendar.current
        let d0 = calr.startOfDay(for: date)
        let key = "\(b.rawValue)|\(d0.timeIntervalSince1970)|\(loc.lat)|\(loc.lon)"
        if let c = pathCache[key] { return c }
        let o = obs
        let d1 = calr.date(byAdding: .day, value: 1, to: d0) ?? d0.addingTimeInterval(86400)
        var pts: [SkyPt] = []
        var t = d0.timeIntervalSince1970
        while t <= d1.timeIntervalSince1970 {
            let p = b == .sun ? Astro.sunPosition(t, o) : Astro.moonPosition(t, o)
            pts.append(SkyPt(az: p.az, alt: p.alt))
            t += 120
        }
        var hours: [HourPt] = []
        for h in 0..<24 {
            if let hd = calr.date(byAdding: .hour, value: h, to: d0) {
                let p = b == .sun ? Astro.sunPosition(hd, o) : Astro.moonPosition(hd, o)
                hours.append(HourPt(h: calr.component(.hour, from: hd), az: p.az, alt: p.alt))
            }
        }
        let ev = b == .sun ? Astro.sunEvents(d0, o) : Astro.moonEvents(d0, o)
        var rs: [RiseSet] = []
        if let r = ev.rise { rs.append(RiseSet(t: r, rise: true, az: position(r, b).az)) }
        if let s = ev.set { rs.append(RiseSet(t: s, rise: false, az: position(s, b).az)) }
        let apex = pts.max(by: { $0.alt < $1.alt }) ?? SkyPt(az: 180, alt: 0)
        let dp = DayPath(pts: pts, hours: hours, ev: ev, rs: rs, apex: apex)
        if pathCache.count > 40 { pathCache.removeAll() }
        pathCache[key] = dp
        return dp
    }

    func seasons(_ year: Int) -> [Date] {
        if let s = seasonCache[year] { return s }
        let s = Astro.seasons(year)
        seasonCache[year] = s
        return s
    }

    // MARK: HUD

    func hudInfo() -> HudInfo {
        let cd = AppModel.cameraDirection(cameraMatrix())
        let when = now()
        let sp = position(when, target)
        var r: String
        if target == .sun {
            r = "☀ \(Int(sp.az.rounded()))° · " + String(format: "%.1f°", sp.alt)
        } else {
            let ph = Astro.moonPhase(when)
            r = "☾ \(Int(sp.az.rounded()))° · " + String(format: "%.1f°", sp.alt) + " · \(Int((ph.illum * 100).rounded()))%"
        }
        if travel != nil { r = L.shortDate(when) + " " + L.time(when) + "  ·  " + r }
        var chip: String? = nil
        var alert = false
        if travel != nil && panel != .travel { chip = "⏱ " + L.t("timeTravel") }
        else if panel == .calibrate { chip = L.t("calibrating") }
        else if loc.src == "approx" { chip = L.t("waitLoc"); alert = true }
        else if started && motion.R == nil && !motion.available { chip = L.t("manual") }
        let deg = "\(Int(Astro.norm360(cd.az).rounded()) % 360)° · " + (cd.alt >= 0 ? "+" : "") + "\(Int(cd.alt.rounded()))°"
        return HudInfo(dir: L.dirName(cd.az), deg: deg, readout: r, chip: chip, alert: alert)
    }

    // MARK: calibration

    /// Shift the calibration so the screen point `pt` shows the computed sun.
    /// Shift the calibration so the screen point `pt` shows the body at `target`.
    func alignPoint(_ pt: CGPoint, _ target: Astro.SunPos) {
        let d = projector(screen).direction(at: pt)
        var c = cal
        c.yaw = Astro.wrap180(c.yaw + Astro.wrap180(target.az - d.az))
        c.pitch = max(-30, min(30, c.pitch + target.alt - d.alt))
        cal = c
    }

    /// Live (not time-travel) position of the tracked body, if it is above the horizon.
    func trackedBodyUp() -> Astro.SunPos? {
        let p = position(Date(), target)
        return p.alt > -0.5 ? p : nil
    }

    func alignCenter() {
        guard let p = trackedBodyUp() else { return }
        alignPoint(CGPoint(x: screen.width / 2, y: screen.height / 2), p)
        showToast(L.t(target == .sun ? "aligned" : "alignedMoon"))
    }

    func resetCalibration() {
        cal = Cal(yaw: 0, pitch: 0, fovAdj: 0, auto: cal.auto)
        detAligned = false
    }

    /// The camera found a bright round blob at normalised picture position `n`:
    /// the Sun by day, or the Moon at night. Align to whichever matches.
    private func handleSun(_ n: CGPoint) {
        camera.detect = cal.auto
        guard cal.auto, cameraOn, motion.R != nil, panel != .calibrate, loc.src != "approx" else { detCount = 0; return }
        let now = Date()
        let sun = Astro.sunPosition(now, obs)
        var candidates: [Astro.SunPos] = []
        if sun.alt > 1 { candidates.append(sun) }
        if sun.altGeo < -3 {
            let moon = Astro.moonPosition(now, obs)
            if moon.alt > 1 { candidates.append(moon) }
        }
        if candidates.isEmpty { detCount = 0; return }
        let W = Double(screen.width), H = Double(screen.height)
        let s = max(W / camera.bufferW, H / camera.bufferH)
        let pt = CGPoint(x: W / 2 + (Double(n.x) - 0.5) * camera.bufferW * s, y: H / 2 + (Double(n.y) - 0.5) * camera.bufferH * s)
        let d = projector(screen).direction(at: pt)
        func error(_ b: Astro.SunPos) -> Double { hypot(Astro.wrap180(b.az - d.az) * cos(b.alt * Astro.D2R), b.alt - d.alt) }
        guard let body = candidates.min(by: { error($0) < error($1) }) else { return }
        let err = error(body)
        // first alignment may fix a larger error; afterwards only small drift
        if err > (detAligned ? 6 : 25) { detCount = 0; return }
        let steady = detCount > 0 && hypot(Astro.wrap180(d.az - detPrevAz) * cos(d.alt * Astro.D2R), d.alt - detPrevAlt) < 0.8
        detCount = steady ? detCount + 1 : 1
        detPrevAz = d.az
        detPrevAlt = d.alt
        if detCount < 3 || err < 0.3 { return }
        alignPoint(pt, body)
        detCount = 0
        detAligned = true
        if !detAnnounced { detAnnounced = true; showToast(L.t(sun.alt > 1 ? "autoAligned" : "autoAlignedMoon")) }
    }

    func setTarget(_ b: SkyBody) {
        guard target != b else { return }
        target = b
        if b == .moon {
            let ph = Astro.moonPhase(now())
            showToast(L.t("moon") + " · " + L.t("phase\(ph.index)") + " · \(Int((ph.illum * 100).rounded()))%")
        } else {
            showToast(L.t("sun"))
        }
    }

    // MARK: time travel / compare / eclipses

    func setTravelMinutes(_ m: Int) {
        let d0 = Calendar.current.startOfDay(for: travel ?? Date())
        travel = Calendar.current.date(byAdding: .minute, value: m, to: d0)
        playing = false
    }
    func shiftTravelDay(_ n: Int) { travel = Calendar.current.date(byAdding: .day, value: n, to: travel ?? Date()) }
    func setTravelDate(_ d: Date) {
        let calr = Calendar.current
        let cur = travel ?? Date()
        let hm = calr.dateComponents([.hour, .minute], from: cur)
        travel = calr.date(bySettingHour: hm.hour ?? 12, minute: hm.minute ?? 0, second: 0, of: d)
    }
    private func updatePlayTimer() {
        playTimer?.invalidate()
        playTimer = nil
        guard playing else { return }
        playTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self, let t = self.travel else { return }
            let d0 = Calendar.current.startOfDay(for: t)
            var n = t.addingTimeInterval(180)
            if Calendar.current.startOfDay(for: n) != d0 { n = d0 }
            self.travel = n
        }
    }

    func openTravel() { if travel == nil { travel = Date() }; panel = .travel }
    func openCompare() {
        if compare == nil {
            let base = now()
            let s = seasons(Calendar.current.component(.year, from: base))
            let month = Calendar.current.component(.month, from: base)
            compare = (month < 4 || month > 9) ? s[1] : s[3]
        }
        panel = .compare
    }
    func comparePreset(_ p: String) {
        let base = now()
        let s = seasons(Calendar.current.component(.year, from: base))
        switch p {
        case "jun": compare = s[1]
        case "dec": compare = s[3]
        case "mar": compare = s[0]
        case "m1": compare = Calendar.current.date(byAdding: .month, value: 1, to: base)
        default: compare = Calendar.current.date(byAdding: .month, value: 6, to: base)
        }
    }

    func loadEclipses() {
        if eclipses != nil { return }
        let o = obs
        DispatchQueue.global(qos: .userInitiated).async {
            let list = Astro.upcomingEclipses(from: Date(), obs: o, count: 8, maxYears: 30)
            DispatchQueue.main.async { self.eclipses = list }
        }
    }
    func showEclipse(_ e: Astro.Eclipse) {
        eclipse = e
        travel = e.max
        playing = false
        sheet = nil
        panel = .travel
    }

    // MARK: misc

    func showToast(_ s: String) {
        toast = s
        toastWork?.cancel()
        let w = DispatchWorkItem { [weak self] in self?.toast = nil }
        toastWork = w
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8, execute: w)
    }

    func toggleSolstice() {
        solstice.toggle()
        showToast(solstice ? L.t("solOn") : L.t("solOff"))
    }

    var orientationName: String {
        switch motion.mode {
        case "true": return L.t("oriTrue")
        case "magnetic": return L.t("oriMag")
        case "relative": return L.t("oriRel")
        default: return L.t("oriNone")
        }
    }
    var compassName: String {
        var s: String
        switch motion.fieldAccuracy {
        case 0: s = L.t("calUncal")
        case 1: s = L.t("calLow")
        case 2: s = L.t("calMed")
        case 3: s = L.t("calHigh")
        default: s = L.t("calUnknown")
        }
        if locSvc.headingAccuracy > 0 { s += " (±\(Int(locSvc.headingAccuracy.rounded()))°)" }
        return s
    }

    /// Camera picture + overlay, saved to Photos.
    @MainActor func takePhoto() {
        let size = screen
        let when = now()
        let pr = projector(size)
        let renderer = ImageRenderer(content:
            Canvas { ctx, _ in OverlayDrawer(m: self, p: pr, when: when).draw(ctx) }
                .frame(width: size.width, height: size.height)
        )
        renderer.scale = 3
        let overlay = renderer.uiImage
        let frame = cameraOn ? camera.snapshot() : nil
        let caption = L.t("appName") + " · " + L.date(when) + " " + L.time(when) + " · " + String(format: "%.3f, %.3f", loc.lat, loc.lon)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            if let f = frame {
                let fs = f.size
                let s = max(size.width / fs.width, size.height / fs.height)
                let w = fs.width * s, h = fs.height * s
                f.draw(in: CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2, width: w, height: h))
            } else {
                UIColor(red: 0.17, green: 0.29, blue: 0.45, alpha: 1).setFill()
                UIRectFill(CGRect(origin: .zero, size: size))
            }
            overlay?.draw(in: CGRect(origin: .zero, size: size))
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.6)
            shadow.shadowBlurRadius = 4
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .shadow: shadow
            ]
            (caption as NSString).draw(at: CGPoint(x: 16, y: size.height - 34), withAttributes: attrs)
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(L.t("saved"))
    }
}
