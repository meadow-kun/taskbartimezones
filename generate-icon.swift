#!/usr/bin/env swift

import Cocoa

func generateIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let center = CGPoint(x: s / 2, y: s / 2)
    let radius = s * 0.42
    let padding = s * 0.08

    // --- Background: rounded rect (macOS icon shape) ---
    let bgRect = CGRect(x: padding, y: padding, width: s - padding * 2, height: s - padding * 2)
    let cornerRadius = s * 0.22
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Gradient background: deep blue
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradColors = [
        CGColor(red: 0.10, green: 0.15, blue: 0.40, alpha: 1.0),
        CGColor(red: 0.05, green: 0.08, blue: 0.25, alpha: 1.0),
    ] as CFArray
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: gradColors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(gradient,
            start: CGPoint(x: s / 2, y: s - padding),
            end: CGPoint(x: s / 2, y: padding),
            options: [])
    }
    ctx.restoreGState()

    // --- Globe ---
    let globeCenter = CGPoint(x: center.x - s * 0.05, y: center.y + s * 0.05)
    let globeRadius = radius * 0.82

    // Globe circle fill
    ctx.saveGState()
    ctx.setFillColor(CGColor(red: 0.20, green: 0.50, blue: 0.85, alpha: 0.5))
    ctx.addArc(center: globeCenter, radius: globeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.fillPath()
    ctx.restoreGState()

    // Globe outline
    ctx.saveGState()
    ctx.setStrokeColor(CGColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.8))
    ctx.setLineWidth(max(s * 0.015, 0.5))
    ctx.addArc(center: globeCenter, radius: globeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.strokePath()
    ctx.restoreGState()

    let lineColor = CGColor(red: 0.5, green: 0.75, blue: 1.0, alpha: 0.5)
    let lineWidth = max(s * 0.01, 0.5)

    // Horizontal lines (latitude)
    ctx.saveGState()
    ctx.setStrokeColor(lineColor)
    ctx.setLineWidth(lineWidth)
    for i in [-0.5, 0.0, 0.5] as [CGFloat] {
        let y = globeCenter.y + globeRadius * i
        // Calculate the width at this latitude
        let latRadius = sqrt(globeRadius * globeRadius - (globeRadius * i) * (globeRadius * i))
        ctx.move(to: CGPoint(x: globeCenter.x - latRadius, y: y))
        ctx.addLine(to: CGPoint(x: globeCenter.x + latRadius, y: y))
    }
    ctx.strokePath()
    ctx.restoreGState()

    // Vertical ellipses (longitude)
    ctx.saveGState()
    ctx.setStrokeColor(lineColor)
    ctx.setLineWidth(lineWidth)
    // Center vertical line
    ctx.move(to: CGPoint(x: globeCenter.x, y: globeCenter.y - globeRadius))
    ctx.addLine(to: CGPoint(x: globeCenter.x, y: globeCenter.y + globeRadius))
    ctx.strokePath()

    // Ellipses for longitude
    for xScale in [0.35, 0.7] as [CGFloat] {
        let ellipseRect = CGRect(
            x: globeCenter.x - globeRadius * xScale,
            y: globeCenter.y - globeRadius,
            width: globeRadius * xScale * 2,
            height: globeRadius * 2
        )
        ctx.addEllipse(in: ellipseRect)
    }
    ctx.strokePath()
    ctx.restoreGState()

    // --- Clock (bottom-right overlay) ---
    let clockRadius = s * 0.22
    let clockCenter = CGPoint(x: center.x + s * 0.18, y: center.y - s * 0.18)

    // Clock background
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.01), blur: s * 0.04,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.4))
    ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    ctx.addArc(center: clockCenter, radius: clockRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.fillPath()
    ctx.restoreGState()

    // Clock border
    ctx.saveGState()
    ctx.setStrokeColor(CGColor(red: 0.3, green: 0.55, blue: 0.85, alpha: 1.0))
    ctx.setLineWidth(max(s * 0.02, 1.0))
    ctx.addArc(center: clockCenter, radius: clockRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.strokePath()
    ctx.restoreGState()

    // Hour markers
    ctx.saveGState()
    ctx.setFillColor(CGColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.6))
    for i in 0..<12 {
        let angle = CGFloat(i) * (.pi / 6) - .pi / 2
        let markerOuter = clockRadius * 0.85
        let markerInner = clockRadius * 0.72
        let outerPt = CGPoint(
            x: clockCenter.x + cos(angle) * markerOuter,
            y: clockCenter.y + sin(angle) * markerOuter
        )
        let dotSize = max(s * 0.02, 1.0)
        ctx.fillEllipse(in: CGRect(
            x: outerPt.x - dotSize / 2,
            y: outerPt.y - dotSize / 2,
            width: dotSize, height: dotSize
        ))
    }
    ctx.restoreGState()

    // Clock hands - showing ~10:10 (classic clock display)
    ctx.saveGState()
    ctx.setLineCap(.round)

    // Hour hand (pointing to ~10)
    let hourAngle: CGFloat = -(.pi / 2) + (.pi / 6) * 10 + (.pi / 360) * 10
    let hourLen = clockRadius * 0.5
    ctx.setStrokeColor(CGColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0))
    ctx.setLineWidth(max(s * 0.025, 1.5))
    ctx.move(to: clockCenter)
    ctx.addLine(to: CGPoint(
        x: clockCenter.x + cos(hourAngle) * hourLen,
        y: clockCenter.y + sin(hourAngle) * hourLen
    ))
    ctx.strokePath()

    // Minute hand (pointing to ~2 / 10 min)
    let minAngle: CGFloat = -(.pi / 2) + (.pi / 30) * 10
    let minLen = clockRadius * 0.7
    ctx.setStrokeColor(CGColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0))
    ctx.setLineWidth(max(s * 0.018, 1.0))
    ctx.move(to: clockCenter)
    ctx.addLine(to: CGPoint(
        x: clockCenter.x + cos(minAngle) * minLen,
        y: clockCenter.y + sin(minAngle) * minLen
    ))
    ctx.strokePath()

    // Center dot
    ctx.setFillColor(CGColor(red: 0.3, green: 0.55, blue: 0.85, alpha: 1.0))
    let dotR = max(s * 0.02, 1.0)
    ctx.fillEllipse(in: CGRect(x: clockCenter.x - dotR, y: clockCenter.y - dotR, width: dotR * 2, height: dotR * 2))

    ctx.restoreGState()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String, pixelSize: Int) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = image.size

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(origin: .zero, size: image.size))
    NSGraphicsContext.restoreGraphicsState()

    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
}

let assetDir = "TaskBarTimeZones/Assets.xcassets/AppIcon.appiconset"

let sizes: [(name: String, pointSize: Int, scale: Int)] = [
    ("icon_16x16",      16,  1),
    ("icon_16x16@2x",   16,  2),
    ("icon_32x32",      32,  1),
    ("icon_32x32@2x",   32,  2),
    ("icon_128x128",    128, 1),
    ("icon_128x128@2x", 128, 2),
    ("icon_256x256",    256, 1),
    ("icon_256x256@2x", 256, 2),
    ("icon_512x512",    512, 1),
    ("icon_512x512@2x", 512, 2),
]

for entry in sizes {
    let pixelSize = entry.pointSize * entry.scale
    let image = generateIcon(size: pixelSize)
    let path = "\(assetDir)/\(entry.name).png"
    savePNG(image, to: path, pixelSize: pixelSize)
    print("Generated: \(path) (\(pixelSize)x\(pixelSize))")
}

print("Done! All icon sizes generated.")
