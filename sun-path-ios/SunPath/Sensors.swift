import Foundation
import CoreMotion
import CoreLocation

/// 3×3 rotation helpers (row-major). World frame is East-North-Up.
enum M3 {
    static func Rz(_ a: Double) -> [Double] {
        let c = cos(a * Astro.D2R), s = sin(a * Astro.D2R)
        return [c, -s, 0, s, c, 0, 0, 0, 1]
    }
    static func Rx(_ a: Double) -> [Double] {
        let c = cos(a * Astro.D2R), s = sin(a * Astro.D2R)
        return [1, 0, 0, 0, c, -s, 0, s, c]
    }
    static func mul(_ A: [Double], _ B: [Double]) -> [Double] {
        var r = [Double](repeating: 0, count: 9)
        for i in 0..<3 {
            for j in 0..<3 {
                r[i * 3 + j] = A[i * 3] * B[j] + A[i * 3 + 1] * B[3 + j] + A[i * 3 + 2] * B[6 + j]
            }
        }
        return r
    }
    static func transpose(_ A: [Double]) -> [Double] { [A[0], A[3], A[6], A[1], A[4], A[7], A[2], A[5], A[8]] }
    static func apply(_ R: [Double], _ v: [Double]) -> [Double] {
        [R[0] * v[0] + R[1] * v[1] + R[2] * v[2], R[3] * v[0] + R[4] * v[1] + R[5] * v[2], R[6] * v[0] + R[7] * v[1] + R[8] * v[2]]
    }
    static func applyT(_ R: [Double], _ v: [Double]) -> [Double] {
        [R[0] * v[0] + R[3] * v[1] + R[6] * v[2], R[1] * v[0] + R[4] * v[1] + R[7] * v[2], R[2] * v[0] + R[5] * v[1] + R[8] * v[2]]
    }
    static func headingOf(_ w: [Double]) -> Double { Astro.norm360(atan2(w[0], w[1]) * Astro.R2D) }
    static func worldVec(_ az: Double, _ alt: Double) -> [Double] {
        let ca = cos(alt * Astro.D2R)
        return [ca * sin(az * Astro.D2R), ca * cos(az * Astro.D2R), sin(alt * Astro.D2R)]
    }
}

/// Phone orientation from Core Motion, referenced to true north when available
/// (the same fused attitude native AR apps use).
final class MotionService {
    private let mm = CMMotionManager()
    /// World (East-North-Up) ← device rotation. nil until the first sample.
    private(set) var R: [Double]? = nil
    private(set) var mode = "none"          // "true", "magnetic", "relative", "none"
    private(set) var fieldAccuracy: Int = -2  // CMMagneticFieldCalibrationAccuracy raw value
    var magneticDecl = 0.0                   // only used in the magnetic fallback
    private var convention = 0               // 0 unknown, 1 = matrix is reference→device, 2 = device→reference
    private var started = false

    var available: Bool { mm.isDeviceMotionAvailable }

    func start() {
        guard mm.isDeviceMotionAvailable, !started else { return }
        started = true
        let frames = CMMotionManager.availableAttitudeReferenceFrames()
        if frames.contains(.xTrueNorthZVertical) { run(.xTrueNorthZVertical, "true") }
        else if frames.contains(.xMagneticNorthZVertical) { run(.xMagneticNorthZVertical, "magnetic") }
        else { run(.xArbitraryCorrectedZVertical, "relative") }
    }

    /// True north needs a location fix; if no samples arrive, fall back to magnetic north.
    func fallbackIfSilent() {
        guard started, R == nil, mode == "true" else { return }
        mm.stopDeviceMotionUpdates()
        if CMMotionManager.availableAttitudeReferenceFrames().contains(.xMagneticNorthZVertical) { run(.xMagneticNorthZVertical, "magnetic") }
        else { run(.xArbitraryCorrectedZVertical, "relative") }
    }

    private func run(_ frame: CMAttitudeReferenceFrame, _ name: String) {
        mode = name
        mm.deviceMotionUpdateInterval = 1.0 / 60.0
        mm.startDeviceMotionUpdates(using: frame, to: OperationQueue.main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            self.update(motion)
        }
    }

    private func update(_ m: CMDeviceMotion) {
        let r = m.attitude.rotationMatrix
        let M: [Double] = [r.m11, r.m12, r.m13, r.m21, r.m22, r.m23, r.m31, r.m32, r.m33]
        let MT = M3.transpose(M)
        // Work out the matrix convention once, from gravity: for the device→reference matrix A,
        // gravity in device coordinates is −(third row of A).
        if convention == 0 {
            let g = m.gravity
            func score(_ A: [Double]) -> Double { -(A[6] * g.x + A[7] * g.y + A[8] * g.z) }
            let s1 = score(MT), s2 = score(M)
            if abs(s1 - s2) > 0.3 { convention = s1 > s2 ? 1 : 2 }
        }
        let A = convention == 2 ? M : MT  // device → reference (X north, Y west, Z up)
        // reference → East-North-Up: E = −Y, N = X, U = Z
        let P: [Double] = [0, -1, 0, 1, 0, 0, 0, 0, 1]
        var W = M3.mul(P, A)
        if mode == "magnetic" { W = M3.mul(M3.Rz(-magneticDecl), W) }
        R = W
        fieldAccuracy = Int(m.magneticField.accuracy.rawValue)
    }
}

/// Location (and heading accuracy for the status screen).
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let lm = CLLocationManager()
    var onLocation: ((CLLocation) -> Void)?
    var onAuthorization: ((Bool) -> Void)?
    private(set) var headingAccuracy: Double = -1
    private var running = false

    override init() {
        super.init()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        lm.distanceFilter = 200
    }

    func start() {
        switch lm.authorizationStatus {
        case .notDetermined: lm.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: begin()
        default: onAuthorization?(false)
        }
    }

    func requestOnce() { if running { lm.requestLocation() } else { start() } }

    private func begin() {
        if running { return }
        running = true
        lm.startUpdatingLocation()
        if CLLocationManager.headingAvailable() { lm.startUpdatingHeading() }
        onAuthorization?(true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: begin()
        case .denied, .restricted: onAuthorization?(false)
        default: break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let l = locations.last { onLocation?(l) }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingAccuracy = newHeading.headingAccuracy
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool { true }
}
