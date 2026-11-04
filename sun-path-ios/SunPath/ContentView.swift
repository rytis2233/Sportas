import SwiftUI

@main
struct SunPathApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView(m: model).preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @ObservedObject var m: AppModel

    var body: some View {
        ZStack {
            Group {
                if m.cameraOn {
                    CameraPreview(session: m.camera.session)
                } else {
                    LinearGradient(colors: [Color(red: 0.05, green: 0.11, blue: 0.2), Color(red: 0.17, green: 0.29, blue: 0.45),
                                            Color(red: 0.49, green: 0.62, blue: 0.75)], startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()

            OverlayLayer(m: m).ignoresSafeArea()

            VStack {
                HUD(m: m).padding(.top, 6)
                Spacer()
            }

            VStack {
                Spacer()
                if m.panel == nil { BottomBar(m: m) } else { PanelHost(m: m) }
            }

            if m.menuOpen { MenuOverlay(m: m) }

            if let t = m.toast {
                VStack {
                    Spacer()
                    Text(t)
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.11).opacity(0.94)))
                        .padding(.horizontal, 24)
                        .padding(.bottom, m.panel == nil ? 100 : 330)
                }
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        .foregroundColor(.white)
        .animation(.easeInOut(duration: 0.2), value: m.toast)
        .sheet(item: $m.sheet) { kind in
            Group {
                switch kind {
                case .about: AboutSheet(m: m)
                case .eclipses: EclipseSheet(m: m)
                case .language: LanguageSheet(m: m)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .preferredColorScheme(.dark)
        }
        .onAppear { m.start() }
    }
}

// MARK: - Overlay with gestures

struct OverlayLayer: View {
    @ObservedObject var m: AppModel
    @State private var last: CGPoint? = nil

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { _ in
                Canvas { ctx, size in
                    OverlayDrawer(m: m, p: m.projector(size), when: m.now()).draw(ctx)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        let prev = last ?? v.startLocation
                        last = v.location
                        let k = m.effectiveFov / Double(max(geo.size.width, geo.size.height))
                        let dx = Double(v.location.x - prev.x) * k, dy = Double(v.location.y - prev.y) * k
                        if m.panel == .calibrate && m.motion.R != nil {
                            var c = m.cal
                            c.yaw = Astro.wrap180(c.yaw - dx * 0.5)
                            c.pitch = max(-30, min(30, c.pitch + dy * 0.5))
                            m.cal = c
                        } else if m.motion.R == nil {
                            m.lookYaw = Astro.norm360(m.lookYaw - dx)
                            m.lookPitch = max(-85, min(85, m.lookPitch + dy))
                        }
                    }
                    .onEnded { v in
                        last = nil
                        let moved = hypot(Double(v.location.x - v.startLocation.x), Double(v.location.y - v.startLocation.y))
                        if m.panel == .calibrate && moved < 10 && m.motion.R != nil, let tb = m.trackedBodyUp() {
                            m.alignPoint(v.location, tb)
                            m.showToast(L.t(m.target == .sun ? "aligned" : "alignedMoon"))
                        }
                    }
            )
            .onAppear { m.screen = geo.size }
            .onChange(of: geo.size) { s in m.screen = s }
        }
    }
}

// MARK: - HUD

struct HUD: View {
    @ObservedObject var m: AppModel
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.15)) { _ in
            let info = m.hudInfo()
            VStack(spacing: 8) {
                Button { if m.travel != nil { m.openTravel() } } label: {
                    VStack(spacing: 1) {
                        Text(info.dir).font(.system(size: 26, weight: .semibold))
                        Text(info.deg).font(.system(size: 12, weight: .medium)).monospacedDigit().foregroundColor(.white.opacity(0.62))
                    }
                    .frame(minWidth: 112)
                    .padding(.horizontal, 22).padding(.vertical, 9)
                    .background(Capsule().fill(Color.black.opacity(0.55)))
                }
                .buttonStyle(.plain)
                Text(info.readout)
                    .font(.system(size: 13, weight: .medium)).monospacedDigit()
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.55)))
                if let chip = info.chip {
                    Text(chip)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(info.alert ? .white : .black)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(info.alert ? Color(red: 0.78, green: 0.24, blue: 0.18) : SunColor))
                }
            }
        }
    }
}

// MARK: - Buttons

struct RoundButton: View {
    let icon: String
    var big = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: big ? 26 : 23, weight: .regular))
                .frame(width: big ? 66 : 54, height: big ? 66 : 54)
                .background(Circle().fill(Color.black.opacity(0.6)))
        }
        .buttonStyle(.plain)
    }
}

struct Pill: View {
    let title: String
    var primary = false
    var small = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: small ? 14 : 15, weight: primary ? .semibold : .medium))
                .lineLimit(1)
                .padding(.horizontal, small ? 12 : 16)
                .frame(height: small ? 34 : 42)
                .foregroundColor(primary ? .black : .white)
                .background(Capsule().fill(primary ? SunColor : Color.gray.opacity(0.3)))
        }
        .buttonStyle(.plain)
    }
}

struct BottomBar: View {
    @ObservedObject var m: AppModel
    var body: some View {
        HStack(spacing: 18) {
            RoundButton(icon: "info.circle") { m.sheet = .about }
            RoundButton(icon: "camera") { m.takePhoto() }
            Spacer(minLength: 4)
            BodySwitch(m: m)
            Spacer(minLength: 4)
            RoundButton(icon: "line.3.horizontal", big: true) { m.menuOpen = true }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

/// Sun / Moon switch on the main screen.
struct BodySwitch: View {
    @ObservedObject var m: AppModel
    var body: some View {
        HStack(spacing: 2) {
            segment("sun.max.fill", .sun, SunColor)
            segment("moon.fill", .moon, MoonColor)
        }
        .padding(4)
        .background(Capsule().fill(Color.black.opacity(0.6)))
    }
    private func segment(_ icon: String, _ b: SkyBody, _ color: Color) -> some View {
        let on = m.target == b
        return Button { m.setTarget(b) } label: {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(on ? .black : .white.opacity(0.85))
                .frame(width: 46, height: 46)
                .background(Circle().fill(on ? color : Color.clear))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L.t(b == .sun ? "sun" : "moon"))
    }
}

// MARK: - Menu

struct MenuOverlay: View {
    @ObservedObject var m: AppModel
    var body: some View {
        ZStack {
            Color.black.opacity(0.42).ignoresSafeArea().onTapGesture { m.menuOpen = false }
            VStack(spacing: 10) {
                item("scope", "calibrate", false) { m.panel = .calibrate }
                item("clock.arrow.circlepath", "travel", m.travel != nil) { m.openTravel() }
                item("arrow.left.arrow.right", "compare", m.compare != nil) { m.openCompare() }
                item("sun.horizon", "solstice", m.solstice) { m.toggleSolstice() }
                item("circle.fill", "eclipses", false) { m.sheet = .eclipses }
                item("globe", "language", false) { m.sheet = .language }
                item(nil, "cancel", false) {}
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 30).fill(Color(white: 0.16).opacity(0.92)))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .frame(maxWidth: 360)
            .padding(.horizontal, 24)
        }
    }

    private func item(_ icon: String?, _ key: String, _ active: Bool, _ action: @escaping () -> Void) -> some View {
        Button {
            m.menuOpen = false
            if m.panel != nil { m.playing = false; m.panel = nil }
            action()
        } label: {
            ZStack {
                Text(L.t(key)).font(.system(size: 17, weight: .medium)).frame(maxWidth: .infinity)
                HStack {
                    if let icon = icon { Image(systemName: icon).font(.system(size: 19)) }
                    Spacer()
                    if active { Circle().fill(SunColor).frame(width: 8, height: 8) }
                }
                .padding(.horizontal, 18)
            }
            .frame(height: 50)
            .background(Capsule().fill(Color.gray.opacity(0.3)))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom panels

struct PanelHost: View {
    @ObservedObject var m: AppModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let p = m.panel {
                switch p {
                case .travel: TravelPanel(m: m)
                case .compare: ComparePanel(m: m)
                case .calibrate: CalibratePanel(m: m)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .frame(maxWidth: 560)
        .background(
            RoundedRectangle(cornerRadius: 22).fill(Color(white: 0.11).opacity(0.94)).ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TravelPanel: View {
    @ObservedObject var m: AppModel
    var body: some View {
        let t = m.travel ?? Date()
        let calr = Calendar.current
        let minutes = calr.component(.hour, from: t) * 60 + calr.component(.minute, from: t)
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(L.time(t)).font(.system(size: 30, weight: .semibold)).monospacedDigit()
                Spacer()
                Text(L.date(t)).font(.system(size: 14)).foregroundColor(.white.opacity(0.62))
            }
            Slider(value: Binding(get: { Double(minutes) }, set: { m.setTravelMinutes(Int($0)) }), in: 0...1439, step: 1)
                .tint(SunColor)
            HStack(spacing: 8) {
                Pill(title: "‹ 1d", small: true) { m.shiftTravelDay(-1) }
                DatePicker("", selection: Binding(get: { t }, set: { m.setTravelDate($0) }), displayedComponents: .date)
                    .labelsHidden()
                Pill(title: "1d ›", small: true) { m.shiftTravelDay(1) }
                Pill(title: m.playing ? "❚❚" : "▶", small: true) { m.playing.toggle() }
            }
            if let e = m.eclipse, calr.isDate(e.max, inSameDayAs: t) {
                Text(L.t("eclipse") + " · \(Int((e.obscuration * 100).rounded()))% " + L.t("obsc"))
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.62))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Pill(title: L.t("begins") + " " + L.time(e.c1), small: true) { m.travel = e.c1; m.playing = false }
                        Pill(title: L.t("max") + " " + L.time(e.max), small: true) { m.travel = e.max; m.playing = false }
                        Pill(title: L.t("ends") + " " + L.time(e.c4), small: true) { m.travel = e.c4; m.playing = false }
                    }
                }
            }
            HStack {
                Pill(title: L.t("now")) { m.travel = nil; m.eclipse = nil; m.playing = false; m.panel = nil }
                Spacer()
                Pill(title: L.t("done"), primary: true) { m.playing = false; m.panel = nil }
            }
        }
    }
}

struct ComparePanel: View {
    @ObservedObject var m: AppModel
    var body: some View {
        let other = m.compare ?? Date()
        let moon = m.target == .moon
        let a = m.dayPath(m.now(), m.target).ev, b = m.dayPath(other, m.target).ev
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L.t("cmpTitle")).font(.system(size: 17, weight: .semibold))
                Spacer()
                DatePicker("", selection: Binding(get: { other }, set: { m.compare = $0 }), displayedComponents: .date)
                    .labelsHidden()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Pill(title: L.t("junSol"), small: true) { m.comparePreset("jun") }
                    Pill(title: L.t("decSol"), small: true) { m.comparePreset("dec") }
                    Pill(title: L.t("marEq"), small: true) { m.comparePreset("mar") }
                    Pill(title: L.t("plus1m"), small: true) { m.comparePreset("m1") }
                    Pill(title: L.t("plus6m"), small: true) { m.comparePreset("m6") }
                }
            }
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 4) {
                GridRow {
                    Text("")
                    Text(L.shortDate(m.now())).fontWeight(.semibold).foregroundColor(SunColor)
                    Text(L.shortDate(other)).fontWeight(.semibold).foregroundColor(CompareColor)
                }
                if moon {
                    row(L.t("moonrise"), L.time(a.rise), L.time(b.rise))
                    row(L.t("moonset"), L.time(a.set), L.time(b.set))
                    row(L.t("maxAlt"), L.deg(a.noonAlt, 1), L.deg(b.noonAlt, 1))
                    row(L.t("illum"), lit(m.now()), lit(other))
                } else {
                    row(L.t("sunrise"), L.time(a.rise), L.time(b.rise))
                    row(L.t("sunset"), L.time(a.set), L.time(b.set))
                    row(L.t("noonAlt"), L.deg(a.noonAlt, 1), L.deg(b.noonAlt, 1))
                    row(L.t("daylength"), length(a), length(b))
                }
            }
            .font(.system(size: 14))
            .monospacedDigit()
            HStack {
                Pill(title: L.t("hideCmp")) { m.compare = nil; m.panel = nil }
                Spacer()
                Pill(title: L.t("done"), primary: true) { m.panel = nil }
            }
        }
    }
    private func row(_ k: String, _ x: String, _ y: String) -> some View {
        GridRow {
            Text(k).foregroundColor(.white.opacity(0.62))
            Text(x)
            Text(y)
        }
    }
    private func length(_ e: Astro.SunEvents) -> String { e.state == "normal" ? L.dur(e.dayLength) : L.t(e.state) }
    private func lit(_ d: Date) -> String { "\(Int((Astro.moonPhase(d).illum * 100).rounded()))%" }
}

struct CalibratePanel: View {
    @ObservedObject var m: AppModel
    var body: some View {
        let sunUp = m.trackedBodyUp() != nil
        let moon = m.target == .moon
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L.t("calibrate")).font(.system(size: 17, weight: .semibold))
                Spacer()
                Text(m.compassName).font(.system(size: 13)).foregroundColor(.white.opacity(0.62))
            }
            Text(moon ? L.t(sunUp ? "calHelpMoon" : "calHelpMoonDown") : L.t(sunUp ? "calHelp" : "calHelpNight"))
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Text(L.t("fov")).font(.system(size: 14)).foregroundColor(.white.opacity(0.62))
                Text(L.deg(m.effectiveFov, 1)).font(.system(size: 14)).monospacedDigit()
                Slider(value: $m.cal.fovAdj, in: -15...15, step: 0.5).tint(SunColor)
            }
            Toggle(L.t("autoAlign"), isOn: $m.cal.auto).font(.system(size: 14)).tint(SunColor)
            HStack(spacing: 10) {
                Pill(title: L.t(moon ? "alignMoon" : "alignSun"), primary: true) { m.alignCenter() }
                    .disabled(!sunUp)
                    .opacity(sunUp ? 1 : 0.4)
                Pill(title: L.t("reset")) { m.resetCalibration() }
                Spacer()
                Pill(title: L.t("done")) { m.panel = nil }
            }
            Text(L.t("offset") + " " + L.signed(m.cal.yaw) + " / " + L.signed(m.cal.pitch))
                .font(.system(size: 13)).foregroundColor(.white.opacity(0.62)).monospacedDigit()
        }
    }
}

// MARK: - Sheets

struct SheetTitle: View {
    let text: String
    var body: some View {
        Text(text).font(.system(size: 22, weight: .bold)).foregroundColor(SunColor).padding(.bottom, 4)
    }
}

struct AboutSheet: View {
    @ObservedObject var m: AppModel
    @State private var editing = false
    @State private var latText = ""
    @State private var lonText = ""

    var body: some View {
        let ev = m.dayPath(Date()).ev
        let mev = m.dayPath(Date(), .moon).ev
        let phase = Astro.moonPhase(Date())
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                SheetTitle(text: L.t("about"))
                section("howTitle", "how")
                section("offlineTitle", "offline")
                section("sensorsTitle", "sensors")
                section("accTitle", "acc")
                Text(L.t("status")).font(.system(size: 16, weight: .semibold)).padding(.top, 12)
                Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                    kv(L.t("location"), String(format: "%.4f, %.4f", m.loc.lat, m.loc.lon) + "\n" + locSource)
                    kv(L.t("orientation"), m.orientationName)
                    kv(L.t("compassCal"), m.compassName)
                    kv(L.t("cameraFov"), m.camera.fov > 10 ? L.deg(m.effectiveFov, 1) : "—")
                    kv(L.t("calibration"), L.signed(m.cal.yaw) + " / " + L.signed(m.cal.pitch))
                    kv(L.t("sunrise"), L.time(ev.rise))
                    kv(L.t("noon"), L.time(ev.noon) + " · " + L.deg(ev.noonAlt, 1))
                    kv(L.t("sunset"), L.time(ev.set))
                    kv(L.t("daylength"), ev.state == "normal" ? L.dur(ev.dayLength) : L.t(ev.state))
                }
                .font(.system(size: 15))
                Text(L.t("moonToday")).font(.system(size: 16, weight: .semibold)).padding(.top, 12)
                Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                    kv(L.t("phase"), L.t("phase\(phase.index)") + " · \(Int((phase.illum * 100).rounded()))%")
                    kv(L.t("moonrise"), mev.state == "normal" ? L.time(mev.rise) : moonState(mev.state))
                    kv(L.t("moonset"), mev.state == "normal" ? L.time(mev.set) : moonState(mev.state))
                    kv(L.t("maxAlt"), L.time(mev.noon) + " · " + L.deg(mev.noonAlt, 1))
                }
                .font(.system(size: 15))
                HStack(spacing: 10) {
                    Pill(title: L.t("edit"), small: true) {
                        latText = String(format: "%.5f", m.loc.lat)
                        lonText = String(format: "%.5f", m.loc.lon)
                        editing = true
                    }
                    Pill(title: L.t("useGps"), small: true) { m.useGPS(); m.sheet = nil }
                }
                .padding(.top, 10)
                if editing {
                    HStack {
                        TextField(L.t("lat"), text: $latText).keyboardType(.numbersAndPunctuation).textFieldStyle(.roundedBorder)
                        TextField(L.t("lon"), text: $lonText).keyboardType(.numbersAndPunctuation).textFieldStyle(.roundedBorder)
                    }
                    Pill(title: L.t("save"), primary: true, small: true) {
                        let la = Double(latText.replacingOccurrences(of: ",", with: ".")) ?? 999
                        let lo = Double(lonText.replacingOccurrences(of: ",", with: ".")) ?? 999
                        if abs(la) <= 90 && abs(lo) <= 180 {
                            m.loc = Loc(lat: la, lon: lo, h: 0, src: "manual")
                            editing = false
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func moonState(_ s: String) -> String { s == "polarDay" ? L.t("moonNeverSets") : L.t("moonNeverRises") }
    private var locSource: String {
        m.loc.src == "gps" ? L.t("gps") : (m.loc.src == "manual" ? L.t("manualLoc") : L.t("approxLoc"))
    }
    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L.t(title)).font(.system(size: 16, weight: .semibold))
            Text(L.t(body)).font(.system(size: 15)).foregroundColor(.white.opacity(0.62)).fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 10)
    }
    private func kv(_ k: String, _ v: String) -> some View {
        GridRow {
            Text(k).foregroundColor(.white.opacity(0.62))
            Text(v).multilineTextAlignment(.trailing).frame(maxWidth: .infinity, alignment: .trailing).monospacedDigit()
        }
    }
}

struct EclipseDiagram: View {
    let disks: Astro.Disks
    var body: some View {
        Canvas { ctx, size in
            let R = 22.0, k = R / disks.rS
            let cx = Double(size.width) / 2, cy = Double(size.height) / 2
            let dx = Astro.wrap180(disks.moon.az - disks.sun.az) * cos(disks.sun.alt * Astro.D2R) * k
            let dy = -(disks.moon.alt - disks.sun.alt) * k
            let mr = R * disks.rM / disks.rS
            ctx.fill(Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: 2 * R, height: 2 * R)), with: .color(SunColor))
            var c = ctx
            c.clip(to: Path(ellipseIn: CGRect(x: cx - 30, y: cy - 30, width: 60, height: 60)))
            let mrect = CGRect(x: cx + dx - mr, y: cy + dy - mr, width: 2 * mr, height: 2 * mr)
            c.fill(Path(ellipseIn: mrect), with: .color(Color(white: 0.18)))
            c.stroke(Path(ellipseIn: mrect), with: .color(.white.opacity(0.25)), lineWidth: 1)
        }
        .frame(width: 64, height: 64)
    }
}

struct EclipseSheet: View {
    @ObservedObject var m: AppModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                SheetTitle(text: L.t("eclTitle"))
                Text(L.t("eclIntro")).font(.system(size: 15)).foregroundColor(.white.opacity(0.62))
                if let list = m.eclipses {
                    if list.isEmpty {
                        Text(L.t("noEcl")).foregroundColor(.white.opacity(0.62)).padding(.vertical, 18)
                    }
                    ForEach(list) { e in
                        Button { m.showEclipse(e) } label: { row(e) }
                            .buttonStyle(.plain)
                        Divider().background(Color.white.opacity(0.2))
                    }
                } else {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(L.t("calcing")).foregroundColor(.white.opacity(0.62))
                    }
                    .padding(.vertical, 18)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { m.loadEclipses() }
    }

    private func row(_ e: Astro.Eclipse) -> some View {
        let here = e.local == "total" ? L.t("hereTotal") : (e.local == "annular" ? L.t("hereAnnular") : L.t("herePartial"))
        var notes: [String] = []
        if e.risesEclipsed { notes.append(L.t("risesE")) }
        if e.setsEclipsed { notes.append(L.t("setsE")) }
        return HStack(spacing: 14) {
            EclipseDiagram(disks: Astro.sunMoonDisks(e.max, m.obs))
            VStack(alignment: .leading, spacing: 3) {
                Text(L.longDate(e.max)).font(.system(size: 16, weight: .semibold))
                Text(L.t(e.global) + " · " + here + " · \(Int((e.obscuration * 100).rounded()))% " + L.t("obsc"))
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.62))
                Text(L.time(e.c1) + " → " + L.time(e.max) + " → " + L.time(e.c4) + " · " + L.t("sunAlt") + " " + L.deg(e.sunAltMax))
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.62)).monospacedDigit()
                Text(notes.isEmpty ? L.t("showSky") + " ›" : notes.joined(separator: " · "))
                    .font(.system(size: 13)).foregroundColor(SunColor)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

struct LanguageSheet: View {
    @ObservedObject var m: AppModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetTitle(text: L.t("language")).padding(.bottom, 8)
            choice("English", "en")
            Divider().background(Color.white.opacity(0.2))
            choice("Lietuvių", "lt")
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
    }
    private func choice(_ name: String, _ code: String) -> some View {
        Button {
            m.lang = code
            m.sheet = nil
        } label: {
            HStack {
                Text(name).font(.system(size: 17))
                Spacer()
                if m.lang == code { Image(systemName: "checkmark").foregroundColor(SunColor) }
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
