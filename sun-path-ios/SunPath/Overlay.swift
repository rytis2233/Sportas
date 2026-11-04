import SwiftUI

let SunColor = Color(red: 1.0, green: 0.78, blue: 0.16)
let SunDeep = Color(red: 1.0, green: 0.58, blue: 0.10)
let SunLight = Color(red: 1.0, green: 0.97, blue: 0.84)
let CompareColor = Color(red: 0.36, green: 0.80, blue: 1.0)
let JuneColor = Color(red: 1.0, green: 0.52, blue: 0.38)
let DecemberColor = Color(red: 0.56, green: 0.71, blue: 1.0)
let MoonColor = Color(red: 0.86, green: 0.90, blue: 0.97)
let NorthColor = Color(red: 1.0, green: 0.42, blue: 0.40)

/// SF Rounded, used across the app.
func rounded(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
    .system(size: size, weight: weight, design: .rounded)
}

/// Draws the sky overlay: horizon, compass, altitude scale, paths and the Sun or Moon.
struct OverlayDrawer {
    let m: AppModel
    let p: Projector
    let when: Date

    func draw(_ ctx: GraphicsContext) {
        let cd = AppModel.cameraDirection(p.cam)
        let moon = m.target == .moon
        if !m.cameraOn { drawGround(ctx, cd.az, cd.alt) }

        // Lines and labels share one soft shadow — a single offscreen pass per frame.
        var shaded = ctx
        shaded.addFilter(.shadow(color: .black.opacity(0.45), radius: 2.5))
        shaded.drawLayer { layer in
            if m.solstice && !moon {
                let s = m.seasons(Calendar.current.component(.year, from: when))
                drawDay(layer, m.dayPath(s[1]), JuneColor, width: 2.5, dashAlpha: 0.45, hours: false, events: false, label: L.shortDate(s[1]))
                drawDay(layer, m.dayPath(s[3]), DecemberColor, width: 2.5, dashAlpha: 0.45, hours: false, events: false, label: L.shortDate(s[3]))
                drawDay(layer, m.dayPath(s[0]), Color.white.opacity(0.7), width: 1.8, dashAlpha: 0.35, hours: false, events: false, label: L.t("equinox"))
            }
            drawHorizon(layer, cd.az)
            if let c = m.compare {
                drawDay(layer, m.dayPath(c, m.target), CompareColor, width: 3.5, dashAlpha: 0.7, hours: true, events: true, label: L.shortDate(c))
            }
            drawDay(layer, m.dayPath(when, m.target), moon ? MoonColor : SunColor, width: 4.5, dashAlpha: 0.75, hours: true, events: true,
                    label: m.compare != nil ? L.shortDate(when) : nil)
        }

        if moon {
            drawMoon(ctx, Astro.moonPosition(when, m.obs), Astro.sunPosition(when, m.obs))
        } else {
            drawSun(ctx, Astro.sunPosition(when, m.obs))
        }
        drawCrosshair(ctx, strong: m.panel == .calibrate)
    }

    // MARK: helpers

    private func label(_ ctx: GraphicsContext, _ s: String, _ pt: CGPoint, size: CGFloat, weight: Font.Weight = .semibold,
                       color: Color = .white, opacity: Double = 1, anchor: UnitPoint = .center) {
        var c = ctx
        c.opacity = opacity
        c.draw(Text(s).font(rounded(size, weight)).foregroundColor(color), at: pt, anchor: anchor)
    }

    private func circle(_ x: Double, _ y: Double, _ r: Double) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r))
    }

    private func drawGround(_ ctx: GraphicsContext, _ camAz: Double, _ camAlt: Double) {
        var pts: [CGPoint] = []
        for a in stride(from: -85.0, through: 85.0, by: 5.0) {
            if let s = p.project(camAz + a, 0) { pts.append(s) }
        }
        var path = Path()
        if pts.count < 2 {
            if camAlt < 0 { path.addRect(CGRect(x: 0, y: 0, width: p.w, height: p.h)) }
        } else {
            pts.sort { $0.x < $1.x }
            path.move(to: pts[0])
            for q in pts { path.addLine(to: q) }
            path.addLine(to: CGPoint(x: pts[pts.count - 1].x, y: 100000))
            path.addLine(to: CGPoint(x: pts[0].x, y: 100000))
            path.closeSubpath()
        }
        ctx.fill(path, with: .linearGradient(Gradient(colors: [Color(red: 0.16, green: 0.18, blue: 0.21), Color(red: 0.06, green: 0.07, blue: 0.08)]),
                                             startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: p.h)))
    }

    /// Solid with a soft glow above the horizon, thinner and dashed below.
    private func strokeSky(_ ctx: GraphicsContext, _ pts: [SkyPt], _ color: Color, width: CGFloat, dashAlpha: Double) {
        let maxJump = max(p.w, p.h) * 1.5
        func drawRun(_ run: [SkyPt], _ dashed: Bool) {
            if run.count < 2 { return }
            var path = Path()
            var pen = false
            var last: CGPoint? = nil
            for q in run {
                guard let s = p.project(q.az, q.alt) else { pen = false; last = nil; continue }
                if let l = last, hypot(Double(s.x - l.x), Double(s.y - l.y)) > maxJump { pen = false }
                if pen { path.addLine(to: s) } else { path.move(to: s); pen = true }
                last = s
            }
            var c = ctx
            if dashed {
                c.opacity = dashAlpha
                c.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width * 0.7, lineCap: .round, lineJoin: .round, dash: [10, 9]))
            } else {
                c.stroke(path, with: .color(color.opacity(0.25)), style: StrokeStyle(lineWidth: width + 7, lineCap: .round, lineJoin: .round))
                c.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
        }
        var run: [SkyPt] = []
        var above: Bool? = nil
        for q in pts {
            if q.alt < -35 {
                if !run.isEmpty { drawRun(run, above == false) }
                run = []
                above = nil
                continue
            }
            let a = q.alt >= 0
            if above == nil { above = a }
            if a != above {
                run.append(q)
                drawRun(run, above == false)
                run = [q]
                above = a
            } else {
                run.append(q)
            }
        }
        if !run.isEmpty { drawRun(run, above == false) }
    }

    private func drawHorizon(_ ctx: GraphicsContext, _ camAz: Double) {
        var path = Path()
        var pen = false
        var last: CGPoint? = nil
        for a in stride(from: 0.0, through: 360.0, by: 2.0) {
            guard let s = p.project(a, 0) else { pen = false; last = nil; continue }
            if let l = last, abs(Double(s.x - l.x)) > p.w * 1.5 { pen = false }
            if pen { path.addLine(to: s) } else { path.move(to: s); pen = true }
            last = s
        }
        var hc = ctx
        hc.opacity = 0.85
        hc.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [14, 12]))

        let dirs = L.dirs
        for a in stride(from: 0, to: 360, by: 10) {
            guard let s = p.project(Double(a), 0), Double(s.x) > -40, Double(s.x) < p.w + 40 else { continue }
            let major = a % 45 == 0
            let north = a == 0
            var tick = Path()
            tick.move(to: CGPoint(x: s.x, y: s.y + 8))
            tick.addLine(to: CGPoint(x: s.x, y: s.y + (major ? 34 : 15)))
            ctx.stroke(tick, with: .color((north ? NorthColor : Color.white).opacity(major ? 0.95 : 0.4)),
                       style: StrokeStyle(lineWidth: major ? 2.2 : 1.3, lineCap: .round))
            if major {
                label(ctx, dirs[(a / 45) * 2], CGPoint(x: s.x, y: s.y - 20), size: a % 90 == 0 ? 22 : 18, weight: .bold,
                      color: north ? NorthColor : .white, opacity: 0.95)
            } else if a % 30 == 0 {
                label(ctx, "\(a)°", CGPoint(x: s.x, y: s.y + 26), size: 11, weight: .medium, opacity: 0.55)
            }
        }
        for alt in [-30, -15, 15, 30, 45, 60, 75] {
            guard let s = p.project(camAz, Double(alt)), Double(s.y) > 120, Double(s.y) < p.h - 130 else { continue }
            var ln = Path()
            ln.move(to: CGPoint(x: 0, y: s.y))
            ln.addLine(to: CGPoint(x: 26, y: s.y))
            ctx.stroke(ln, with: .color(.white.opacity(0.7)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            label(ctx, "\(alt)°", CGPoint(x: 33, y: s.y), size: 13, weight: .semibold, opacity: 0.75, anchor: .leading)
        }
    }

    private func drawDay(_ ctx: GraphicsContext, _ dp: DayPath, _ color: Color, width: CGFloat, dashAlpha: Double,
                         hours: Bool, events: Bool, label lab: String?) {
        strokeSky(ctx, dp.pts, color, width: width, dashAlpha: dashAlpha)
        if hours {
            let proj: [CGPoint?] = dp.hours.map { p.project($0.az, $0.alt) }
            for i in 0..<dp.hours.count {
                let h = dp.hours[i]
                guard h.alt >= -8, let s = proj[i] else { continue }
                var nx = 0.0, ny = 1.0
                var nb: CGPoint? = nil
                if i + 1 < proj.count { nb = proj[i + 1] }
                if nb == nil && i > 0 { nb = proj[i - 1] }
                if let b = nb {
                    let tx = Double(b.x - s.x), ty = Double(b.y - s.y)
                    let l = max(1e-6, hypot(tx, ty))
                    nx = -ty / l
                    ny = tx / l
                    if ny < 0 { nx = -nx; ny = -ny }
                }
                var c = ctx
                c.opacity = h.alt < 0 ? 0.6 : 1
                let x = Double(s.x), y = Double(s.y)
                c.fill(circle(x, y, Double(width) + 1.6), with: .color(color))
                c.fill(circle(x, y, Double(width) * 0.42), with: .color(Color(white: 0.12)))
                label(ctx, String(format: "%02d", h.h), CGPoint(x: x + nx * 18, y: y + ny * 18),
                      size: 12, weight: .bold, color: color, opacity: h.alt < 0 ? 0.55 : 0.95)
            }
        }
        if events {
            for r in dp.rs {
                guard let s = p.project(r.az, 0) else { continue }
                let x = Double(s.x), y = Double(s.y)
                var tri = Path()
                if r.rise {
                    tri.move(to: CGPoint(x: x, y: y - 29))
                    tri.addLine(to: CGPoint(x: x - 7, y: y - 18))
                    tri.addLine(to: CGPoint(x: x + 7, y: y - 18))
                } else {
                    tri.move(to: CGPoint(x: x, y: y - 17))
                    tri.addLine(to: CGPoint(x: x - 7, y: y - 28))
                    tri.addLine(to: CGPoint(x: x + 7, y: y - 28))
                }
                tri.closeSubpath()
                ctx.fill(tri, with: .color(color))
                label(ctx, L.time(r.t), CGPoint(x: x, y: y - 42), size: 13, weight: .bold, color: color)
            }
        }
        if let lab = lab, let s = p.project(dp.apex.az, dp.apex.alt), s.y > 190 {
            label(ctx, lab, CGPoint(x: s.x, y: s.y - 18), size: 13, weight: .bold, color: color)
        }
    }

    // MARK: Sun, Moon, arrows

    private func onScreen(_ s: CGPoint) -> Bool {
        Double(s.x) > -60 && Double(s.x) < p.w + 60 && Double(s.y) > -60 && Double(s.y) < p.h + 60
    }

    private func drawSun(_ ctx: GraphicsContext, _ pos: Astro.SunPos) {
        guard let s = p.project(pos.az, pos.alt), onScreen(s) else {
            drawEdgeArrow(ctx, pos, SunColor)
            return
        }
        let x = Double(s.x), y = Double(s.y), r = 19.0
        var c = ctx
        c.opacity = pos.alt < -0.83 ? 0.55 : 1
        // halo
        c.fill(circle(x, y, r * 2.8), with: .radialGradient(
            Gradient(colors: [SunColor.opacity(0.55), SunColor.opacity(0.16), SunColor.opacity(0)]),
            center: s, startRadius: r * 0.7, endRadius: r * 2.8))
        // disk: warm gradient, light from the upper left
        c.fill(circle(x, y, r), with: .radialGradient(
            Gradient(colors: [SunLight, SunColor, SunDeep]),
            center: CGPoint(x: x - r * 0.3, y: y - r * 0.3), startRadius: 0, endRadius: r * 1.35))
        c.stroke(circle(x, y, r), with: .color(.white.opacity(0.75)), lineWidth: 1.2)
        // eclipse: the Moon crossing the marker, scaled with it
        if let e = m.eclipse, when >= e.c1.addingTimeInterval(-1800), when <= e.c4.addingTimeInterval(1800) {
            let md = Astro.sunMoonDisks(when, m.obs)
            if let ms = p.project(md.moon.az, md.moon.alt + (pos.alt - md.sun.alt)) {
                let k = r / (p.f * md.rS * Astro.D2R)
                let mx = x + Double(ms.x - s.x) * k, my = y + Double(ms.y - s.y) * k
                var c3 = ctx
                c3.clip(to: circle(x, y, r * 2.8))
                c3.fill(circle(mx, my, r * md.rM / md.rS), with: .color(Color(red: 0.07, green: 0.08, blue: 0.10)))
                c3.stroke(circle(mx, my, r * md.rM / md.rS), with: .color(.white.opacity(0.35)), lineWidth: 1)
            }
        }
    }

    /// The Moon with its real phase; the lit side faces the Sun.
    private func drawMoon(_ ctx: GraphicsContext, _ pos: Astro.SunPos, _ sun: Astro.SunPos) {
        guard let s = p.project(pos.az, pos.alt), onScreen(s) else {
            drawEdgeArrow(ctx, pos, MoonColor)
            return
        }
        let phase = Astro.moonPhase(when)
        // direction from the Moon towards the Sun in the image
        let mc = M3.applyT(p.cam, M3.worldVec(pos.az, pos.alt))
        let sc = M3.applyT(p.cam, M3.worldVec(sun.az, sun.alt))
        let dot = mc[0] * sc[0] + mc[1] * sc[1] + mc[2] * sc[2]
        let ang = atan2(-(sc[1] - dot * mc[1]), sc[0] - dot * mc[0])
        let x = Double(s.x), y = Double(s.y), r = 19.0
        var c = ctx
        c.opacity = pos.alt < -0.83 ? 0.55 : 1
        c.fill(circle(x, y, r * 2.6), with: .radialGradient(
            Gradient(colors: [MoonColor.opacity(0.10 + 0.25 * phase.illum), MoonColor.opacity(0)]),
            center: s, startRadius: r * 0.8, endRadius: r * 2.6))
        c.fill(circle(x, y, r), with: .color(Color(red: 0.13, green: 0.15, blue: 0.19).opacity(0.92)))
        // lit part = half disk towards the Sun ± the terminator ellipse
        let k = phase.illum
        var pts: [CGPoint] = []
        let n = 40
        for i in 0...n {
            let th = -Double.pi / 2 + Double.pi * Double(i) / Double(n)
            pts.append(CGPoint(x: r * cos(th), y: r * sin(th)))
        }
        for i in 0...n {
            let th = Double.pi / 2 - Double.pi * Double(i) / Double(n)
            pts.append(CGPoint(x: -(2 * k - 1) * r * cos(th), y: r * sin(th)))
        }
        var lit = Path()
        lit.addLines(pts.map { q in
            CGPoint(x: x + Double(q.x) * cos(ang) - Double(q.y) * sin(ang), y: y + Double(q.x) * sin(ang) + Double(q.y) * cos(ang))
        })
        lit.closeSubpath()
        c.fill(lit, with: .radialGradient(Gradient(colors: [Color.white, Color(red: 0.88, green: 0.90, blue: 0.93)]),
                                          center: s, startRadius: 0, endRadius: r))
        c.stroke(circle(x, y, r), with: .color(.white.opacity(0.5)), lineWidth: 1)
    }

    /// Off screen: a small marker at the edge with an arrow pointing towards the body.
    private func drawEdgeArrow(_ ctx: GraphicsContext, _ pos: Astro.SunPos, _ color: Color) {
        let d = M3.applyT(p.cam, M3.worldVec(pos.az, pos.alt))
        var dx = d[0], dy = -d[1]
        if hypot(dx, dy) < 1e-6 { dx = 1 }
        let n = hypot(dx, dy)
        dx /= n
        dy /= n
        let mx = p.w / 2 - 44, my = p.h / 2 - 160
        let k = min(mx / max(abs(dx), 1e-9), my / max(abs(dy), 1e-9))
        let x = p.w / 2 + dx * k, y = p.h / 2 + dy * k, ang = atan2(dy, dx)
        func rot(_ px: Double, _ py: Double) -> CGPoint {
            CGPoint(x: x + px * cos(ang) - py * sin(ang), y: y + px * sin(ang) + py * cos(ang))
        }
        var c = ctx
        c.opacity = pos.alt < -0.83 ? 0.55 : 1
        c.addFilter(.shadow(color: .black.opacity(0.45), radius: 4))
        c.fill(circle(x, y, 13), with: .color(color))
        c.stroke(circle(x, y, 13), with: .color(.white.opacity(0.8)), lineWidth: 1.5)
        var tri = Path()
        tri.move(to: rot(29, 0))
        tri.addLine(to: rot(19, -7))
        tri.addLine(to: rot(19, 7))
        tri.closeSubpath()
        c.fill(tri, with: .color(color))
    }

    /// Thin crosshair with an open centre; in calibrate mode a coloured ring.
    private func drawCrosshair(_ ctx: GraphicsContext, strong: Bool) {
        let cx = p.w / 2, cy = p.h / 2
        let inner = strong ? 26.0 : 9.0, outer = strong ? 48.0 : 64.0
        var path = Path()
        path.move(to: CGPoint(x: cx - outer, y: cy)); path.addLine(to: CGPoint(x: cx - inner, y: cy))
        path.move(to: CGPoint(x: cx + inner, y: cy)); path.addLine(to: CGPoint(x: cx + outer, y: cy))
        path.move(to: CGPoint(x: cx, y: cy - outer)); path.addLine(to: CGPoint(x: cx, y: cy - inner))
        path.move(to: CGPoint(x: cx, y: cy + inner)); path.addLine(to: CGPoint(x: cx, y: cy + outer))
        let color = strong ? (m.target == .moon ? MoonColor : SunColor) : Color.white.opacity(0.7)
        var c = ctx
        c.addFilter(.shadow(color: .black.opacity(0.35), radius: 2))
        c.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: strong ? 2 : 1.4, lineCap: .round))
        if strong { c.stroke(circle(cx, cy, 20), with: .color(color), lineWidth: 2) }
    }
}
