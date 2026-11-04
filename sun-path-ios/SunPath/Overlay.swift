import SwiftUI

let SunColor = Color(red: 1.0, green: 0.76, blue: 0.055)
let CompareColor = Color(red: 0.31, green: 0.76, blue: 0.97)
let JuneColor = Color(red: 1.0, green: 0.54, blue: 0.31)
let DecemberColor = Color(red: 0.51, green: 0.69, blue: 1.0)
let MoonColor = Color(red: 0.84, green: 0.88, blue: 0.94)

/// Draws the sky overlay: horizon, compass, altitude scale, sun paths and the sun.
struct OverlayDrawer {
    let m: AppModel
    let p: Projector
    let when: Date

    func draw(_ ctx: GraphicsContext) {
        let cd = AppModel.cameraDirection(p.cam)
        if !m.cameraOn { drawGround(ctx, cd.az, cd.alt) }
        let moon = m.target == .moon
        let pathColor = moon ? MoonColor : SunColor
        if m.solstice && !moon {
            let s = m.seasons(Calendar.current.component(.year, from: when))
            drawDay(ctx, m.dayPath(s[1]), JuneColor, width: 3, dashAlpha: 0.5, hours: false, events: false, label: L.shortDate(s[1]))
            drawDay(ctx, m.dayPath(s[3]), DecemberColor, width: 3, dashAlpha: 0.5, hours: false, events: false, label: L.shortDate(s[3]))
            drawDay(ctx, m.dayPath(s[0]), Color.white.opacity(0.75), width: 2, dashAlpha: 0.4, hours: false, events: false, label: L.t("equinox"))
        }
        drawHorizon(ctx, cd.az)
        if let c = m.compare {
            drawDay(ctx, m.dayPath(c, m.target), CompareColor, width: 4, dashAlpha: 0.8, hours: true, events: true, label: L.shortDate(c))
        }
        drawDay(ctx, m.dayPath(when, m.target), pathColor, width: 5, dashAlpha: 0.8, hours: true, events: true,
                label: m.compare != nil ? L.shortDate(when) : nil)
        if moon {
            drawMoon(ctx, Astro.moonPosition(when, m.obs), Astro.sunPosition(when, m.obs))
        } else {
            drawSun(ctx, Astro.sunPosition(when, m.obs))
        }
        drawCrosshair(ctx, strong: m.panel == .calibrate)
    }

    private func label(_ ctx: GraphicsContext, _ s: String, _ pt: CGPoint, size: CGFloat, weight: Font.Weight = .semibold,
                       color: Color = .white, opacity: Double = 1, anchor: UnitPoint = .center) {
        var c = ctx
        c.opacity = opacity
        c.addFilter(.shadow(color: .black.opacity(0.6), radius: 2))
        c.draw(Text(s).font(.system(size: size, weight: weight)).foregroundColor(color), at: pt, anchor: anchor)
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
        ctx.fill(path, with: .linearGradient(Gradient(colors: [Color(red: 0.16, green: 0.18, blue: 0.21), Color(red: 0.07, green: 0.08, blue: 0.09)]),
                                             startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: p.h)))
    }

    /// Solid above the horizon, dashed below.
    private func strokeSky(_ ctx: GraphicsContext, _ pts: [SkyPt], _ color: Color, width: CGFloat, dashAlpha: Double) {
        var c = ctx
        c.addFilter(.shadow(color: .black.opacity(0.35), radius: 3))
        let shaded = c
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
            var cc = shaded
            cc.opacity = dashed ? dashAlpha : 1
            cc.stroke(path, with: .color(color),
                      style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dashed ? [12, 11] : []))
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
        var c = ctx
        c.addFilter(.shadow(color: .black.opacity(0.35), radius: 2))
        var path = Path()
        var pen = false
        var last: CGPoint? = nil
        for a in stride(from: 0.0, through: 360.0, by: 2.0) {
            guard let s = p.project(a, 0) else { pen = false; last = nil; continue }
            if let l = last, abs(Double(s.x - l.x)) > p.w * 1.5 { pen = false }
            if pen { path.addLine(to: s) } else { path.move(to: s); pen = true }
            last = s
        }
        var hc = c
        hc.opacity = 0.9
        hc.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 3, dash: [16, 13]))
        let dirs = L.dirs
        for a in stride(from: 0, to: 360, by: 10) {
            guard let s = p.project(Double(a), 0), Double(s.x) > -40, Double(s.x) < p.w + 40 else { continue }
            let major = a % 45 == 0
            var tick = Path()
            tick.move(to: CGPoint(x: s.x, y: s.y + 8))
            tick.addLine(to: CGPoint(x: s.x, y: s.y + (major ? 40 : 16)))
            c.stroke(tick, with: .color(.white.opacity(major ? 0.9 : 0.45)), lineWidth: major ? 2.5 : 1.5)
            if major {
                label(ctx, dirs[(a / 45) * 2], CGPoint(x: s.x, y: s.y - 22), size: 22, opacity: 0.95)
            } else if a % 30 == 0 {
                label(ctx, "\(a)", CGPoint(x: s.x, y: s.y + 28), size: 11, weight: .medium, opacity: 0.6)
            }
        }
        for alt in [-30, -15, 15, 30, 45, 60, 75] {
            guard let s = p.project(camAz, Double(alt)), Double(s.y) > 90, Double(s.y) < p.h - 120 else { continue }
            var ln = Path()
            ln.move(to: CGPoint(x: 0, y: s.y))
            ln.addLine(to: CGPoint(x: 44, y: s.y))
            c.stroke(ln, with: .color(.white.opacity(0.75)), lineWidth: 2)
            label(ctx, "\(alt)°", CGPoint(x: 54, y: s.y), size: 18, weight: .medium, opacity: 0.8, anchor: .leading)
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
                c.opacity = h.alt < 0 ? 0.7 : 1
                let r = Double(width) * 0.9 + 1.5
                let rect = CGRect(x: Double(s.x) - r, y: Double(s.y) - r, width: 2 * r, height: 2 * r)
                c.fill(Path(ellipseIn: rect), with: .color(color))
                c.stroke(Path(ellipseIn: rect), with: .color(.black.opacity(0.55)), lineWidth: 2)
                label(ctx, String(format: "%02d", h.h), CGPoint(x: Double(s.x) + nx * 19, y: Double(s.y) + ny * 19),
                      size: 13, color: color, opacity: h.alt < 0 ? 0.6 : 0.95)
            }
        }
        if events {
            for r in dp.rs {
                guard let s = p.project(r.az, 0) else { continue }
                var tri = Path()
                if r.rise {
                    tri.move(to: CGPoint(x: s.x, y: s.y - 30))
                    tri.addLine(to: CGPoint(x: s.x - 8, y: s.y - 18))
                    tri.addLine(to: CGPoint(x: s.x + 8, y: s.y - 18))
                } else {
                    tri.move(to: CGPoint(x: s.x, y: s.y - 16))
                    tri.addLine(to: CGPoint(x: s.x - 8, y: s.y - 28))
                    tri.addLine(to: CGPoint(x: s.x + 8, y: s.y - 28))
                }
                tri.closeSubpath()
                var c = ctx
                c.addFilter(.shadow(color: .black.opacity(0.5), radius: 2))
                c.fill(tri, with: .color(color))
                label(ctx, L.time(r.t), CGPoint(x: s.x, y: s.y - 44), size: 14, color: color)
            }
        }
        if let lab = lab, let s = p.project(dp.apex.az, dp.apex.alt), s.y > 170 {
            label(ctx, lab, CGPoint(x: s.x, y: s.y - 18), size: 14, color: color)
        }
    }

    private func drawSun(_ ctx: GraphicsContext, _ pos: Astro.SunPos) {
        let below = pos.alt < -0.83
        if let s = p.project(pos.az, pos.alt), Double(s.x) > -60, Double(s.x) < p.w + 60, Double(s.y) > -60, Double(s.y) < p.h + 60 {
            let r = 22.0
            let glow = CGRect(x: Double(s.x) - r * 1.75, y: Double(s.y) - r * 1.75, width: r * 3.5, height: r * 3.5)
            var c = ctx
            c.opacity = below ? 0.55 : 1
            c.fill(Path(ellipseIn: glow), with: .color(SunColor.opacity(0.30)))
            var c2 = c
            c2.addFilter(.shadow(color: .black.opacity(0.35), radius: 4))
            c2.fill(Path(ellipseIn: CGRect(x: Double(s.x) - r, y: Double(s.y) - r, width: 2 * r, height: 2 * r)), with: .color(SunColor))
            // eclipse: the Moon crossing the marker, scaled with it
            if let e = m.eclipse, when >= e.c1.addingTimeInterval(-1800), when <= e.c4.addingTimeInterval(1800) {
                let md = Astro.sunMoonDisks(when, m.obs)
                if let ms = p.project(md.moon.az, md.moon.alt + (pos.alt - md.sun.alt)) {
                    let sunPx = p.f * md.rS * Astro.D2R
                    let k = r / sunPx
                    let mx = Double(s.x) + Double(ms.x - s.x) * k, my = Double(s.y) + Double(ms.y - s.y) * k
                    let mr = r * md.rM / md.rS
                    var c3 = ctx
                    c3.clip(to: Path(ellipseIn: glow))
                    let mrect = CGRect(x: mx - mr, y: my - mr, width: 2 * mr, height: 2 * mr)
                    c3.fill(Path(ellipseIn: mrect), with: .color(Color(red: 0.08, green: 0.09, blue: 0.11)))
                    c3.stroke(Path(ellipseIn: mrect), with: .color(.white.opacity(0.35)), lineWidth: 1)
                }
            }
            return
        }
        drawEdgeArrow(ctx, pos, SunColor)
    }

    /// Off screen: a marker at the edge with an arrow pointing to the body.
    private func drawEdgeArrow(_ ctx: GraphicsContext, _ pos: Astro.SunPos, _ color: Color) {
        let below = pos.alt < -0.83
        let d = M3.applyT(p.cam, M3.worldVec(pos.az, pos.alt))
        var dx = d[0], dy = -d[1]
        if hypot(dx, dy) < 1e-6 { dx = 1 }
        let n = hypot(dx, dy)
        dx /= n
        dy /= n
        let mx = p.w / 2 - 46, my = p.h / 2 - 150
        let k = min(mx / max(abs(dx), 1e-9), my / max(abs(dy), 1e-9))
        let x = p.w / 2 + dx * k, y = p.h / 2 + dy * k, ang = atan2(dy, dx)
        func rot(_ px: Double, _ py: Double) -> CGPoint {
            CGPoint(x: x + px * cos(ang) - py * sin(ang), y: y + px * sin(ang) + py * cos(ang))
        }
        var c = ctx
        c.opacity = below ? 0.55 : 0.95
        c.addFilter(.shadow(color: .black.opacity(0.5), radius: 3))
        c.fill(Path(ellipseIn: CGRect(x: x - 11, y: y - 11, width: 22, height: 22)), with: .color(color))
        var tri = Path()
        tri.move(to: rot(30, 0))
        tri.addLine(to: rot(17, -9))
        tri.addLine(to: rot(17, 9))
        tri.closeSubpath()
        c.fill(tri, with: .color(color))
    }

    /// The Moon with its real phase; the lit side faces the Sun.
    private func drawMoon(_ ctx: GraphicsContext, _ pos: Astro.SunPos, _ sun: Astro.SunPos) {
        guard let s = p.project(pos.az, pos.alt), Double(s.x) > -60, Double(s.x) < p.w + 60, Double(s.y) > -60, Double(s.y) < p.h + 60 else {
            drawEdgeArrow(ctx, pos, MoonColor)
            return
        }
        let phase = Astro.moonPhase(when)
        // direction from the Moon towards the Sun, in the camera image
        let mc = M3.applyT(p.cam, M3.worldVec(pos.az, pos.alt))
        let sc = M3.applyT(p.cam, M3.worldVec(sun.az, sun.alt))
        let dot = mc[0] * sc[0] + mc[1] * sc[1] + mc[2] * sc[2]
        let ux = sc[0] - dot * mc[0], uy = sc[1] - dot * mc[1]
        let ang = atan2(-uy, ux)
        let r = 22.0
        let cx = Double(s.x), cy = Double(s.y)
        var c = ctx
        c.opacity = pos.alt < -0.83 ? 0.55 : 1
        c.fill(Path(ellipseIn: CGRect(x: cx - r * 1.7, y: cy - r * 1.7, width: r * 3.4, height: r * 3.4)), with: .color(MoonColor.opacity(0.16)))
        let disk = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r))
        var c2 = c
        c2.addFilter(.shadow(color: .black.opacity(0.4), radius: 4))
        c2.fill(disk, with: .color(Color(red: 0.16, green: 0.18, blue: 0.22)))
        // lit part: the half-disk towards the Sun plus/minus the terminator ellipse
        let k = phase.illum
        var lit: [CGPoint] = []
        let n = 40
        for i in 0...n {
            let th = -Double.pi / 2 + Double.pi * Double(i) / Double(n)
            lit.append(CGPoint(x: r * cos(th), y: r * sin(th)))
        }
        for i in 0...n {
            let th = Double.pi / 2 - Double.pi * Double(i) / Double(n)
            lit.append(CGPoint(x: -(2 * k - 1) * r * cos(th), y: r * sin(th)))
        }
        var litPath = Path()
        litPath.addLines(lit.map { q in
            CGPoint(x: cx + Double(q.x) * cos(ang) - Double(q.y) * sin(ang), y: cy + Double(q.x) * sin(ang) + Double(q.y) * cos(ang))
        })
        litPath.closeSubpath()
        c.fill(litPath, with: .color(Color(red: 0.95, green: 0.96, blue: 0.93)))
        c.stroke(disk, with: .color(.white.opacity(0.45)), lineWidth: 1)
    }

    private func drawCrosshair(_ ctx: GraphicsContext, strong: Bool) {
        let cx = p.w / 2, cy = p.h / 2, L2 = strong ? 46.0 : 86.0
        var path = Path()
        path.move(to: CGPoint(x: cx - L2, y: cy))
        path.addLine(to: CGPoint(x: cx + L2, y: cy))
        path.move(to: CGPoint(x: cx, y: cy - L2))
        path.addLine(to: CGPoint(x: cx, y: cy + L2))
        if strong { path.addEllipse(in: CGRect(x: cx - 22, y: cy - 22, width: 44, height: 44)) }
        ctx.stroke(path, with: .color(strong ? SunColor : .white.opacity(0.75)), lineWidth: strong ? 2 : 1.5)
    }
}
