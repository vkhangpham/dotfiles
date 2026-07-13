import Foundation
import CoreGraphics

func appendLog(_ line: String) {
    let logPath = "/tmp/lofree-scroll-helper.log"
    guard let data = line.data(using: .utf8) else { return }

    if FileManager.default.fileExists(atPath: logPath),
       let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: logPath)) {
        do {
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
            try handle.close()
        } catch {
            try? handle.close()
        }
    } else {
        try? data.write(to: URL(fileURLWithPath: logPath), options: .atomic)
    }
}

let args = Array(CommandLine.arguments.dropFirst())
let totalPixels = Int32(args.first ?? "0") ?? 0
let requestedSteps = Int(args.dropFirst().first ?? "7") ?? 7
let requestedDelayMicros = Int(args.dropFirst(2).first ?? "5000") ?? 5000
let steps = max(1, min(12, requestedSteps))
let delayMicros = max(0, min(20000, requestedDelayMicros))

let timestamp = ISO8601DateFormatter().string(from: Date())
appendLog("\(timestamp) smooth_pixels=\(totalPixels) steps=\(steps) delay_us=\(delayMicros) args=\(args.joined(separator: " "))\n")

guard totalPixels != 0 else {
    exit(0)
}

let sign: Int32 = totalPixels >= 0 ? 1 : -1
let magnitude = abs(Int(totalPixels))
let frameCount = max(1, min(steps, magnitude))
let base = magnitude / frameCount
let remainder = magnitude % frameCount

for i in 0..<frameCount {
    let thisMagnitude = base + (i < remainder ? 1 : 0)
    let delta = Int32(thisMagnitude) * sign

    guard let event = CGEvent(
        scrollWheelEvent2Source: nil,
        units: CGScrollEventUnit.pixel,
        wheelCount: 1,
        wheel1: delta,
        wheel2: 0,
        wheel3: 0
    ) else {
        exit(2)
    }

    // Mark as a continuous/high-resolution scroll event so apps treat it more
    // like a trackpad/wheel gesture than a single coarse line tick.
    event.setIntegerValueField(CGEventField.scrollWheelEventIsContinuous, value: 1)
    event.post(tap: CGEventTapLocation.cghidEventTap)

    if i + 1 < frameCount && delayMicros > 0 {
        usleep(useconds_t(delayMicros))
    }
}
