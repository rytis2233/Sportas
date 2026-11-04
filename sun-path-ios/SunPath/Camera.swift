import Foundation
import AVFoundation
import UIKit
import SwiftUI
import CoreImage

/// Back camera: live preview, the exact field of view, the latest frame (for photos)
/// and a fast search for the sun in the picture.
final class CameraService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "sunpath.camera")
    /// Field of view along the long side of the picture, degrees (0 = unknown).
    private(set) var fov: Double = 0
    /// Portrait picture size (width < height).
    private(set) var bufferW: Double = 3
    private(set) var bufferH: Double = 4
    var detect = true
    /// Called on the main thread with the sun's position in the picture (0…1, portrait).
    var onSun: ((CGPoint) -> Void)?
    private var lastAnalysis: CFTimeInterval = 0
    private var latest: CVPixelBuffer?
    private let lock = NSLock()
    private let ci = CIContext()

    func start(_ done: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted { DispatchQueue.main.async { done(false) }; return }
            self.queue.async {
                let ok = self.configure()
                DispatchQueue.main.async { done(ok) }
            }
        }
    }

    private func configure() -> Bool {
        guard let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: dev) else { return false }
        session.beginConfiguration()
        if session.canAddInput(input) { session.addInput(input) }
        // A 4:3 format around 1920×1440 keeps the whole field of view without 12 MP frames.
        if let f = CameraService.pickFormat(dev), (try? dev.lockForConfiguration()) != nil {
            dev.activeFormat = f
            dev.unlockForConfiguration()
        } else if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }
        let out = AVCaptureVideoDataOutput()
        out.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        out.alwaysDiscardsLateVideoFrames = true
        out.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(out) { session.addOutput(out) }
        if let c = out.connection(with: .video), c.isVideoOrientationSupported { c.videoOrientation = .portrait }
        session.commitConfiguration()
        let f = Double(dev.activeFormat.videoFieldOfView)
        let dims = CMVideoFormatDescriptionGetDimensions(dev.activeFormat.formatDescription)
        session.startRunning()
        DispatchQueue.main.async {
            self.fov = f
            let a = Double(max(dims.width, dims.height)), b = Double(min(dims.width, dims.height))
            if a > 0 && b > 0 { self.bufferW = b; self.bufferH = a }
        }
        return true
    }

    private static func pickFormat(_ dev: AVCaptureDevice) -> AVCaptureDevice.Format? {
        var best: AVCaptureDevice.Format? = nil
        var bestFov: Float = 0, bestW: Int32 = 0
        for f in dev.formats {
            let d = CMVideoFormatDescriptionGetDimensions(f.formatDescription)
            guard d.height > 0, d.width >= 1280, d.width <= 2100 else { continue }
            guard abs(Double(d.width) / Double(d.height) - 4.0 / 3.0) < 0.02 else { continue }
            guard f.videoSupportedFrameRateRanges.contains(where: { $0.maxFrameRate >= 29 }) else { continue }
            let fov = f.videoFieldOfView
            if fov > bestFov + 0.5 || (abs(fov - bestFov) <= 0.5 && d.width > bestW) {
                best = f; bestFov = fov; bestW = d.width
            }
        }
        return best
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lock.lock(); latest = pb; lock.unlock()
        let now = CACurrentMediaTime()
        guard detect, now - lastAnalysis > 0.4 else { return }
        lastAnalysis = now
        if let p = CameraService.findSun(pb) {
            DispatchQueue.main.async { self.onSun?(p) }
        }
    }

    /// The latest camera frame (portrait).
    func snapshot() -> UIImage? {
        lock.lock(); let pb = latest; lock.unlock()
        guard let buffer = pb else { return nil }
        let img = CIImage(cvPixelBuffer: buffer)
        guard let cg = ci.createCGImage(img, from: img.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    /// The sun = the largest compact blob of saturated pixels. Returns its centre (0…1).
    static func findSun(_ pb: CVPixelBuffer) -> CGPoint? {
        CVPixelBufferLockBaseAddress(pb, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pb, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(pb) else { return nil }
        let w = CVPixelBufferGetWidth(pb), h = CVPixelBufferGetHeight(pb), bpr = CVPixelBufferGetBytesPerRow(pb)
        let step = max(1, w / 120)
        let tw = w / step, th = h / step
        if tw < 8 || th < 8 { return nil }
        let ptr = base.assumingMemoryBound(to: UInt8.self)
        let N = tw * th
        var lum = [Int](repeating: 0, count: N)
        var mx = 0
        for j in 0..<th {
            let row = ptr + (j * step) * bpr
            for i in 0..<tw {
                let p = row + (i * step) * 4 // BGRA
                let l = (Int(p[2]) * 54 + Int(p[1]) * 183 + Int(p[0]) * 19) >> 8
                lum[j * tw + i] = l
                if l > mx { mx = l }
            }
        }
        if mx < 245 { return nil }
        let thr = mx - 4
        var lab = [Bool](repeating: false, count: N)
        var stack: [Int] = []
        var bestArea = 0, bestCx = 0.0, bestCy = 0.0, bestW = 0, bestH = 0
        for start in 0..<N {
            if lum[start] < thr || lab[start] { continue }
            var area = 0, sx = 0, sy = 0, x0 = tw, x1 = 0, y0 = th, y1 = 0
            lab[start] = true
            stack.append(start)
            while let j = stack.popLast() {
                let x = j % tw, y = j / tw
                area += 1; sx += x; sy += y
                if x < x0 { x0 = x }; if x > x1 { x1 = x }; if y < y0 { y0 = y }; if y > y1 { y1 = y }
                if x > 0 && !lab[j - 1] && lum[j - 1] >= thr { lab[j - 1] = true; stack.append(j - 1) }
                if x < tw - 1 && !lab[j + 1] && lum[j + 1] >= thr { lab[j + 1] = true; stack.append(j + 1) }
                if y > 0 && !lab[j - tw] && lum[j - tw] >= thr { lab[j - tw] = true; stack.append(j - tw) }
                if y < th - 1 && !lab[j + tw] && lum[j + tw] >= thr { lab[j + tw] = true; stack.append(j + tw) }
            }
            if area > bestArea {
                bestArea = area
                bestCx = Double(sx) / Double(area); bestCy = Double(sy) / Double(area)
                bestW = x1 - x0 + 1; bestH = y1 - y0 + 1
            }
        }
        // too small, or a bright cloud / overexposed sky
        if bestArea < 3 || Double(bestArea) > Double(N) * 0.08 { return nil }
        // not round: glint, window frame
        let aspect = Double(bestW) / Double(bestH)
        if aspect < 0.45 || aspect > 2.2 || Double(bestArea) / Double(bestW * bestH) < 0.4 { return nil }
        return CGPoint(x: (bestCx + 0.5) / Double(tw), y: (bestCy + 0.5) / Double(th))
    }
}

final class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewUIView {
        let v = PreviewUIView()
        v.backgroundColor = .black
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}
