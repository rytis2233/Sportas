import SwiftUI
import UIKit

@main
struct SunPathApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView(m: model).preferredColorScheme(.dark)
        }
    }
}

// MARK: - Style helpers

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }
}

extension View {
    /// Frosted glass with a hairline edge.
    func glass<S: Shape>(_ shape: S, strong: Bool = false) -> some View {
        self
            .background(strong ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(.ultraThinMaterial), in: shape)
            .overlay(shape.stroke(Color.white.opacity(0.14), lineWidth: 0.8))
    }
}

/// Buttons shrink slightly while pressed.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

let Secondary = Color.white.opacity(0.62)
let SoftCard = Color.white.opacity(0.06)

// MARK: - Main screen

struct ContentView: View {
    @ObservedObject var m: AppModel

    var body: some View {
        ZStack {
            Group {
                if m.cameraOn {
                    CameraPreview(session: m.camera.session)
                } else {
                    LinearGradient(colors: [Color(red: 0.04, green: 0.08, blue: 0.16), Color(red: 0.14, green: 0.25, blue: 0.42),
                                            Color(red: 0.45, green: 0.60, blue: 0.76)], startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()

            OverlayLayer(m: m).ignoresSafeArea()

            // soft vignette so the controls read on bright skies
            VStack {
                LinearGradient(colors: [Color.black.opacity(0.35), .clear], startPoint: .top, endPoint: .bottom).frame(height: 170)
                Spacer()
                LinearGradient(colors: [.clear, Color.black.opacity(0.35)], startPoint: .top, endPoint: .bottom).frame(height: 190)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                HUD(m: m).padding(.top, 4)
                Spacer()
            }

            VStack {
                Spacer()
                if m.panel == nil {
                    BottomBar(m: m).transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    PanelHost(m: m).transition(.move(edge: .bottom))
                }
            }

            if m.menuOpen { MenuOverlay(m: m).transition(.opacity) }

            if let t = m.toast {
                VStack {
                    Text(t)
                        .font(rounded(15, .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18).padding(.vertical, 11)
                        .glass(Capsule(), strong: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 150)
                    Spacer()
                }
                .allowsHitTesting(false)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .foregroundColor(.white)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: m.toast)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: m.menuOpen)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: m.panel)
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
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { _ in
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
                            Haptics.tap()
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
            let moon = m.target == .moon
            VStack(spacing: 8) {
                Button { if m.travel != nil { m.openTravel() } } label: {
                    VStack(spacing: 0) {
                        Text(info.dir).font(rounded(25, .bold))
                        Text(info.deg).font(rounded(12, .semibold)).monospacedDigit().foregroundColor(Secondary)
                    }
                    .frame(minWidth: 104)
                    .padding(.horizontal, 20).padding(.vertical, 8)
                    .glass(Capsule())
                }
                .buttonStyle(PressStyle())

                HStack(spacing: 7) {
                    Image(systemName: moon ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(moon ? MoonColor : SunColor)
                    Text(info.readout).monospacedDigit()
                }
                .font(rounded(13, .semibold))
                .padding(.horizontal, 13).padding(.vertical, 7)
                .glass(Capsule())

                if let chip = info.chip {
                    HStack(spacing: 7) {
                        Circle().fill(info.alert ? NorthColor : SunColor).frame(width: 7, height: 7)
                        Text(chip)
                    }
                    .font(rounded(13, .semibold))
                    .padding(.horizontal, 13).padding(.vertical, 7)
                    .glass(Capsule())
                }
            }
        }
    }
}

// MARK: - Buttons

struct GlassButton: View {
    let icon: String
    var size: CGFloat = 50
    let action: () -> Void
    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .frame(width: size, height: size)
                .glass(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(PressStyle())
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
                .font(rounded(small ? 14 : 15, primary ? .bold : .semibold))
                .lineLimit(1)
                .padding(.horizontal, small ? 13 : 18)
                .frame(height: small ? 34 : 44)
                .foregroundColor(primary ? .black : .white)
                .background(
                    Capsule().fill(primary
                        ? AnyShapeStyle(LinearGradient(colors: [SunLight, SunColor], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.13)))
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
    }
}

struct BottomBar: View {
    @ObservedObject var m: AppModel
    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                GlassButton(icon: "info") { m.sheet = .about }
                GlassButton(icon: "camera") { m.takePhoto() }
                Spacer()
                GlassButton(icon: "line.3.horizontal", size: 58) { m.menuOpen = true }
            }
            BodySwitch(m: m)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
}

/// Sun / Moon switch on the main screen, with a sliding highlight.
struct BodySwitch: View {
    @ObservedObject var m: AppModel
    @Namespace private var ns
    var body: some View {
        HStack(spacing: 0) {
            segment("sun.max.fill", .sun, SunColor)
            segment("moon.fill", .moon, MoonColor)
        }
        .padding(4)
        .glass(Capsule())
    }
    private func segment(_ icon: String, _ b: SkyBody, _ color: Color) -> some View {
        let on = m.target == b
        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) { m.setTarget(b) }
        } label: {
            ZStack {
                if on {
                    Capsule()
                        .fill(LinearGradient(colors: [Color.white.opacity(0.95), color], startPoint: .top, endPoint: .bottom))
                        .matchedGeometryEffect(id: "selection", in: ns)
                }
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(on ? .black : .white.opacity(0.8))
            }
            .frame(width: 50, height: 42)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L.t(b == .sun ? "sun" : "moon"))
    }
}

// MARK: - Menu (action sheet)

struct MenuOverlay: View {
    @ObservedObject var m: AppModel
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { m.menuOpen = false }
            VStack(spacing: 10) {
                VStack(spacing: 0) {
                    item("scope", "calibrate", SunColor, false) { m.panel = .calibrate }
                    divider
                    item("clock.arrow.circlepath", "travel", Color(red: 0.45, green: 0.66, blue: 1.0), m.travel != nil) { m.openTravel() }
                    divider
                    item("arrow.left.arrow.right", "compare", CompareColor, m.compare != nil) { m.openCompare() }
                    divider
                    item("sun.horizon.fill", "solstice", JuneColor, m.solstice) { m.toggleSolstice() }
                    divider
                    item("circle.lefthalf.filled", "eclipses", Color(red: 0.75, green: 0.6, blue: 1.0), false) { m.sheet = .eclipses }
                    divider
                    item("globe", "language", Color(red: 0.45, green: 0.85, blue: 0.6), false) { m.sheet = .language }
                }
                .glass(RoundedRectangle(cornerRadius: 26, style: .continuous), strong: true)

                Button { m.menuOpen = false } label: {
                    Text(L.t("cancel")).font(rounded(17, .bold))
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .glass(RoundedRectangle(cornerRadius: 26, style: .continuous), strong: true)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
            }
            .frame(maxWidth: 420)
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom))
        }
    }

    private var divider: some View { Rectangle().fill(Color.white.opacity(0.1)).frame(height: 0.7).padding(.leading, 62) }

    private func item(_ icon: String, _ key: String, _ tint: Color, _ active: Bool, _ action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            m.menuOpen = false
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(tint.opacity(0.18)))
                Text(L.t(key)).font(rounded(17, .semibold))
                Spacer()
                if active {
                    Text("●").font(.system(size: 10)).foregroundColor(tint)
                } else {
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom panels

struct PanelHost: View {
    @ObservedObject var m: AppModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Capsule().fill(Color.white.opacity(0.25)).frame(width: 36, height: 5).frame(maxWidth: .infinity)
            if let p = m.panel {
                switch p {
                case .travel: TravelPanel(m: m)
                case .compare: ComparePanel(m: m)
                case .calibrate: CalibratePanel(m: m)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .frame(maxWidth: 560)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.regularMaterial)
                .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.8))
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct PanelTitle: View {
    let icon: String
    let text: String
    let tint: Color
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(tint)
            Text(text)
        }
        .font(rounded(17, .bold))
    }
}

struct TravelPanel: View {
    @ObservedObject var m: AppModel
    var body: some View {
        let t = m.travel ?? Date()
        let calr = Calendar.current
        let minutes = calr.component(.hour, from: t) * 60 + calr.component(.minute, from: t)
        let tint = m.target == .moon ? MoonColor : SunColor
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(L.time(t)).font(rounded(38, .bold)).monospacedDigit()
                Spacer()
                Text(L.date(t)).font(rounded(15, .medium)).foregroundColor(Secondary)
            }
            Slider(value: Binding(get: { Double(minutes) }, set: { m.setTravelMinutes(Int($0)) }), in: 0...1439, step: 1)
                .tint(tint)
            HStack(spacing: 8) {
                Pill(title: "‹ 1d", small: true) { m.shiftTravelDay(-1) }
                DatePicker("", selection: Binding(get: { t }, set: { m.setTravelDate($0) }), displayedComponents: .date)
                    .labelsHidden()
                Pill(title: "1d ›", small: true) { m.shiftTravelDay(1) }
                Spacer(minLength: 0)
                Button { m.playing.toggle() } label: {
                    Image(systemName: m.playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(tint))
                }
                .buttonStyle(PressStyle())
            }
            if let e = m.eclipse, calr.isDate(e.max, inSameDayAs: t) {
                Text(L.t("eclipse") + " · \(Int((e.obscuration * 100).rounded()))% " + L.t("obsc"))
                    .font(rounded(14, .semibold)).foregroundColor(Secondary)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PanelTitle(icon: "arrow.left.arrow.right", text: L.t("cmpTitle"), tint: CompareColor)
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
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                GridRow {
                    Text("")
                    Text(L.shortDate(m.now())).font(rounded(14, .bold)).foregroundColor(moon ? MoonColor : SunColor)
                    Text(L.shortDate(other)).font(rounded(14, .bold)).foregroundColor(CompareColor)
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
            .font(rounded(14, .medium))
            .monospacedDigit()
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SoftCard))
            HStack {
                Pill(title: L.t("hideCmp")) { m.compare = nil; m.panel = nil }
                Spacer()
                Pill(title: L.t("done"), primary: true) { m.panel = nil }
            }
        }
    }
    private func row(_ k: String, _ x: String, _ y: String) -> some View {
        GridRow {
            Text(k).foregroundColor(Secondary)
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
        let up = m.trackedBodyUp() != nil
        let moon = m.target == .moon
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PanelTitle(icon: "scope", text: L.t("calibrate"), tint: moon ? MoonColor : SunColor)
                Spacer()
                Text(m.compassName).font(rounded(12, .medium)).foregroundColor(Secondary)
            }
            Text(moon ? L.t(up ? "calHelpMoon" : "calHelpMoonDown") : L.t(up ? "calHelp" : "calHelpNight"))
                .font(rounded(14, .medium)).foregroundColor(Secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 4) {
                HStack {
                    Text(L.t("fov")).foregroundColor(Secondary)
                    Spacer()
                    Text(L.deg(m.effectiveFov, 1)).monospacedDigit()
                }
                .font(rounded(14, .semibold))
                Slider(value: $m.cal.fovAdj, in: -15...15, step: 0.5).tint(moon ? MoonColor : SunColor)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SoftCard))
            Toggle(L.t("autoAlign"), isOn: $m.cal.auto).font(rounded(14, .semibold)).tint(SunColor)
            HStack(spacing: 10) {
                Pill(title: L.t(moon ? "alignMoon" : "alignSun"), primary: true) { Haptics.tap(); m.alignCenter() }
                    .disabled(!up)
                    .opacity(up ? 1 : 0.4)
                Pill(title: L.t("reset")) { m.resetCalibration() }
                Spacer()
                Pill(title: L.t("done")) { m.panel = nil }
            }
            Text(L.t("offset") + " " + L.signed(m.cal.yaw) + " / " + L.signed(m.cal.pitch))
                .font(rounded(12, .medium)).foregroundColor(Secondary).monospacedDigit()
        }
    }
}

// MARK: - Sheets

struct SheetTitle: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(SunColor)
            Text(text)
        }
        .font(rounded(24, .bold))
        .padding(.bottom, 4)
    }
}

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(SoftCard))
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
            VStack(alignment: .leading, spacing: 12) {
                SheetTitle(icon: "sun.max.fill", text: L.t("about"))

                Card {
                    heading("sun.max.fill", L.t("today"), SunColor)
                    Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                        kv(L.t("sunrise"), L.time(ev.rise))
                        kv(L.t("noon"), L.time(ev.noon) + " · " + L.deg(ev.noonAlt, 1))
                        kv(L.t("sunset"), L.time(ev.set))
                        kv(L.t("daylength"), ev.state == "normal" ? L.dur(ev.dayLength) : L.t(ev.state))
                    }
                    .font(rounded(15, .medium))
                }
                Card {
                    heading("moon.fill", L.t("moonToday"), MoonColor)
                    Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                        kv(L.t("phase"), L.t("phase\(phase.index)") + " · \(Int((phase.illum * 100).rounded()))%")
                        kv(L.t("moonrise"), mev.state == "normal" ? L.time(mev.rise) : moonState(mev.state))
                        kv(L.t("moonset"), mev.state == "normal" ? L.time(mev.set) : moonState(mev.state))
                        kv(L.t("maxAlt"), L.time(mev.noon) + " · " + L.deg(mev.noonAlt, 1))
                    }
                    .font(rounded(15, .medium))
                }
                Card {
                    heading("gauge.with.dots.needle.33percent", L.t("status"), CompareColor)
                    Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                        kv(L.t("location"), String(format: "%.4f, %.4f", m.loc.lat, m.loc.lon) + "\n" + locSource)
                        kv(L.t("orientation"), m.orientationName)
                        kv(L.t("compassCal"), m.compassName)
                        kv(L.t("cameraFov"), m.camera.fov > 10 ? L.deg(m.effectiveFov, 1) : "—")
                        kv(L.t("calibration"), L.signed(m.cal.yaw) + " / " + L.signed(m.cal.pitch))
                    }
                    .font(rounded(15, .medium))
                    HStack(spacing: 10) {
                        Pill(title: L.t("edit"), small: true) {
                            latText = String(format: "%.5f", m.loc.lat)
                            lonText = String(format: "%.5f", m.loc.lon)
                            editing = true
                        }
                        Pill(title: L.t("useGps"), small: true) { m.useGPS(); m.sheet = nil }
                    }
                    .padding(.top, 6)
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
                Card {
                    section("howTitle", "how")
                    section("offlineTitle", "offline")
                    section("sensorsTitle", "sensors")
                    section("accTitle", "acc")
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
        }
    }

    private func heading(_ icon: String, _ text: String, _ tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(tint)
            Text(text)
        }
        .font(rounded(16, .bold))
        .padding(.bottom, 2)
    }
    private func moonState(_ s: String) -> String { s == "polarDay" ? L.t("moonNeverSets") : L.t("moonNeverRises") }
    private var locSource: String {
        m.loc.src == "gps" ? L.t("gps") : (m.loc.src == "manual" ? L.t("manualLoc") : L.t("approxLoc"))
    }
    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(L.t(title)).font(rounded(15, .bold))
            Text(L.t(body)).font(.system(size: 14)).foregroundColor(Secondary).fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 6)
    }
    private func kv(_ k: String, _ v: String) -> some View {
        GridRow {
            Text(k).foregroundColor(Secondary)
            Text(v).multilineTextAlignment(.trailing).frame(maxWidth: .infinity, alignment: .trailing).monospacedDigit()
        }
    }
}

struct EclipseDiagram: View {
    let disks: Astro.Disks
    var body: some View {
        Canvas { ctx, size in
            let R = 21.0, k = R / disks.rS
            let cx = Double(size.width) / 2, cy = Double(size.height) / 2
            let dx = Astro.wrap180(disks.moon.az - disks.sun.az) * cos(disks.sun.alt * Astro.D2R) * k
            let dy = -(disks.moon.alt - disks.sun.alt) * k
            let mr = R * disks.rM / disks.rS
            ctx.fill(Path(ellipseIn: CGRect(x: cx - R * 1.4, y: cy - R * 1.4, width: R * 2.8, height: R * 2.8)),
                     with: .radialGradient(Gradient(colors: [SunColor.opacity(0.35), SunColor.opacity(0)]),
                                           center: CGPoint(x: cx, y: cy), startRadius: R * 0.8, endRadius: R * 1.4))
            ctx.fill(Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: 2 * R, height: 2 * R)),
                     with: .radialGradient(Gradient(colors: [SunLight, SunColor, SunDeep]),
                                           center: CGPoint(x: cx - 6, y: cy - 6), startRadius: 0, endRadius: R * 1.35))
            var c = ctx
            c.clip(to: Path(ellipseIn: CGRect(x: cx - 31, y: cy - 31, width: 62, height: 62)))
            let mrect = CGRect(x: cx + dx - mr, y: cy + dy - mr, width: 2 * mr, height: 2 * mr)
            c.fill(Path(ellipseIn: mrect), with: .color(Color(red: 0.11, green: 0.12, blue: 0.15)))
            c.stroke(Path(ellipseIn: mrect), with: .color(.white.opacity(0.25)), lineWidth: 1)
        }
        .frame(width: 64, height: 64)
    }
}

struct EclipseSheet: View {
    @ObservedObject var m: AppModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                SheetTitle(icon: "circle.lefthalf.filled", text: L.t("eclTitle"))
                Text(L.t("eclIntro")).font(rounded(15, .medium)).foregroundColor(Secondary)
                if let list = m.eclipses {
                    if list.isEmpty {
                        Text(L.t("noEcl")).foregroundColor(Secondary).padding(.vertical, 18)
                    }
                    ForEach(list) { e in
                        Button { m.showEclipse(e) } label: { row(e) }
                            .buttonStyle(PressStyle())
                    }
                } else {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(L.t("calcing")).foregroundColor(Secondary)
                    }
                    .padding(.vertical, 18)
                }
            }
            .padding(.horizontal, 18)
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
                Text(L.longDate(e.max)).font(rounded(17, .bold))
                Text(L.t(e.global) + " · " + here)
                    .font(rounded(13, .medium)).foregroundColor(Secondary)
                Text(L.time(e.c1) + " → " + L.time(e.max) + " → " + L.time(e.c4))
                    .font(rounded(14, .semibold)).monospacedDigit()
                HStack(spacing: 6) {
                    Text("\(Int((e.obscuration * 100).rounded()))% " + L.t("obsc"))
                    Text("·")
                    Text(L.t("sunAlt") + " " + L.deg(e.sunAltMax))
                }
                .font(rounded(13, .medium)).foregroundColor(Secondary)
                Text(notes.isEmpty ? L.t("showSky") + " ›" : notes.joined(separator: " · "))
                    .font(rounded(13, .bold)).foregroundColor(SunColor)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(SoftCard))
        .contentShape(Rectangle())
    }
}

struct LanguageSheet: View {
    @ObservedObject var m: AppModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SheetTitle(icon: "globe", text: L.t("language"))
            VStack(spacing: 0) {
                choice("English", "en")
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 0.7)
                choice("Lietuvių", "lt")
            }
            .padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(SoftCard))
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
    }
    private func choice(_ name: String, _ code: String) -> some View {
        Button {
            Haptics.select()
            m.lang = code
            m.sheet = nil
        } label: {
            HStack {
                Text(name).font(rounded(17, .semibold))
                Spacer()
                if m.lang == code { Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundColor(SunColor) }
            }
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
