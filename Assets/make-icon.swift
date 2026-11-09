// Draws the WheelFlip logo. Run from the repository root: swift Assets/make-icon.swift
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let space = CGColorSpace(name: CGColorSpace.sRGB)!

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 255) / 255, green: CGFloat(hex >> 8 & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: alpha)
}

func verticalGradient(_ c: CGContext, top: UInt32, bottom: UInt32, from topY: CGFloat, to bottomY: CGFloat) {
    let gradient = CGGradient(colorsSpace: space, colors: [rgb(top), rgb(bottom)] as CFArray, locations: [0, 1])!
    c.drawLinearGradient(gradient, start: CGPoint(x: 0, y: topY), end: CGPoint(x: 0, y: bottomY), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}

// A superellipse matches the continuous corners of macOS icons. A rounded rectangle does not.
func squircle(center: CGFloat, radius: CGFloat) -> CGPath {
    let path = CGMutablePath()
    for i in 0..<720 {
        let t = CGFloat(i) / 720 * 2 * .pi
        let point = CGPoint(x: center + radius * copysign(pow(abs(cos(t)), 0.4), cos(t)),
                            y: center + radius * copysign(pow(abs(sin(t)), 0.4), sin(t)))
        i == 0 ? path.move(to: point) : path.addLine(to: point)
    }
    path.closeSubpath()
    return path
}

func capsule(_ rect: CGRect) -> CGPath {
    let radius = rect.width / 2
    return CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func chevron(_ c: CGContext, y: CGFloat, center x: CGFloat, width: CGFloat, height: CGFloat, up: Bool, line: CGFloat) {
    let direction: CGFloat = up ? 1 : -1
    c.setLineWidth(line)
    c.setLineCap(.round)
    c.setLineJoin(.round)
    c.move(to: CGPoint(x: x - width / 2, y: y - direction * height / 2))
    c.addLine(to: CGPoint(x: x, y: y + direction * height / 2))
    c.addLine(to: CGPoint(x: x + width / 2, y: y - direction * height / 2))
    c.strokePath()
}

// All coordinates use the 1024-point macOS icon grid.
func drawIcon(_ c: CGContext, small: Bool) {
    let tile = squircle(center: 512, radius: 412)
    c.saveGState()
    c.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: rgb(0, 0.32))
    c.addPath(tile)
    c.setFillColor(rgb(0x15171C))
    c.fillPath()
    c.restoreGState()

    c.saveGState()
    c.addPath(tile)
    c.clip()
    verticalGradient(c, top: 0x30343D, bottom: 0x101216, from: 924, to: 100)
    c.restoreGState()

    let well = capsule(CGRect(x: 327, y: 167, width: 370, height: 690))
    c.addPath(well)
    c.setFillColor(rgb(0x08090B))
    c.fillPath()
    c.addPath(well)
    c.setStrokeColor(rgb(0xFFFFFF, 0.10))
    c.setLineWidth(5)
    c.strokePath()

    c.saveGState()
    c.addPath(capsule(CGRect(x: 362, y: 202, width: 300, height: 620)))
    c.clip()
    verticalGradient(c, top: 0xFF8A3D, bottom: 0xFF5A36, from: 822, to: 202)
    c.restoreGState()

    // The ridges turn to noise at 32 pixels and below, so the small sizes omit them and use heavier chevrons.
    if !small {
        c.setStrokeColor(rgb(0xB5300F, 0.85))
        c.setLineWidth(15)
        c.setLineCap(.round)
        for y in [464, 512, 560] as [CGFloat] {
            c.move(to: CGPoint(x: 428, y: y))
            c.addLine(to: CGPoint(x: 596, y: y))
            c.strokePath()
        }
    }

    c.setStrokeColor(rgb(0xFFFFFF))
    let line: CGFloat = small ? 64 : 50
    chevron(c, y: small ? 640 : 674, center: 512, width: 150, height: 76, up: false, line: line)
    chevron(c, y: small ? 384 : 350, center: 512, width: 150, height: 76, up: true, line: line)
}

// All coordinates use the 18-point menu bar grid.
func drawMenuBarGlyph(_ c: CGContext) {
    c.setStrokeColor(rgb(0))
    c.setLineWidth(1.5)
    c.addPath(capsule(CGRect(x: 4.25, y: 0.75, width: 9.5, height: 16.5)))
    c.strokePath()
    chevron(c, y: 12.1, center: 9, width: 4.2, height: 2, up: false, line: 1.5)
    chevron(c, y: 5.9, center: 9, width: 4.2, height: 2, up: true, line: 1.5)
}

func writePNG(path: String, pixels: Int, gridSize: CGFloat, draw: (CGContext) -> Void) {
    let c = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    c.scaleBy(x: CGFloat(pixels) / gridSize, y: CGFloat(pixels) / gridSize)
    draw(c)
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, c.makeImage()!, nil)
    precondition(CGImageDestinationFinalize(destination), "Cannot write \(path)")
}

let iconset = NSTemporaryDirectory() + "WheelFlip-\(UUID().uuidString).iconset"
try FileManager.default.createDirectory(atPath: iconset, withIntermediateDirectories: true)
for (points, scale) in [(16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2)] {
    let pixels = points * scale
    let name = scale == 1 ? "icon_\(points)x\(points).png" : "icon_\(points)x\(points)@2x.png"
    writePNG(path: "\(iconset)/\(name)", pixels: pixels, gridSize: 1024) { drawIcon($0, small: pixels <= 32) }
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconset, "-o", "Assets/AppIcon.icns"]
try iconutil.run()
iconutil.waitUntilExit()
precondition(iconutil.terminationStatus == 0, "iconutil failed")
try FileManager.default.removeItem(atPath: iconset)

writePNG(path: "Assets/logo.png", pixels: 512, gridSize: 1024) { drawIcon($0, small: false) }
writePNG(path: "Assets/MenuBarIconTemplate.png", pixels: 18, gridSize: 18, draw: drawMenuBarGlyph)
writePNG(path: "Assets/MenuBarIconTemplate@2x.png", pixels: 36, gridSize: 18, draw: drawMenuBarGlyph)
