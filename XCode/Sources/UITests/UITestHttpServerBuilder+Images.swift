import Foundation
import Swifter
#if canImport(UIKit)
import UIKit
#else
import Cocoa
typealias UIImage = NSImage
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        return cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
    }

    convenience init?(named name: String) {
        self.init(named: Name(name))
    }

    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let cgImage = cgImage else {
            return nil
        }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
    }
}

typealias UIFont = NSFont

typealias UIColor = NSColor

extension NSColor {
    static let white = NSColor(white: 1, alpha: 1)
}

#endif

extension UITestHttpServerBuilder.EndpointReport {
    func edited(receivedCallCount: Int) -> UITestHttpServerBuilder.EndpointReport {
        UITestHttpServerBuilder.EndpointReport(
            endpoint: endpoint,
            responseCount: responseCount,
            httpRequestCount: receivedCallCount
        )
    }

    func string() -> String {
        return "endpoint: \(endpoint) expected call count:\(responseCount) received call count: \(httpRequestCount)"
    }
}

public extension Sequence where Element == UITestHttpServerBuilder.EndpointReport {
    func filter(_ endpoint: String) -> Element? {
        return self.first { $0.endpoint == endpoint }
    }

    func string() -> String {
        return self.reduce("") { (result, report) -> String in
            return report.string() + result
        }
    }
}

public func encode<T: Encodable>(value: T) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom({ (date, encoder) in
        var container = encoder.singleValueContainer()
        let encodedDate = ISO8601DateFormatter().string(from: date)
        try container.encode(encodedDate)
    })
    return try encoder.encode(value)
}

extension UITestHttpServerBuilder {
    // MARK: Image utilities
    static func drawOnImage(text: String, properties: ImageProperties? = nil) -> Data {
        let size = properties?.size ?? CGSize(width: 500, height: 500)

        #if canImport(UIKit)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(gray: 0.9, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1)
        context.setAlpha(0.9)

        let minSide = min(size.width, size.height)
        let midPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        [0, 0.3, 0.48].forEach { (inset) in
            let x = (size.width - minSide) / 2
            let y = (size .height - minSide) / 2
            context.strokeEllipse(in: CGRect(x: x, y: y, width: minSide, height: minSide).insetBy(dx: minSide * CGFloat(inset), dy: minSide * CGFloat(inset)))
        }
        let off: CGFloat = 20
        context.strokeLineSegments(between: [CGPoint(x: midPoint.x, y: midPoint.y - off), CGPoint(x: midPoint.x, y: midPoint.y + off)])
        context.strokeLineSegments(between: [CGPoint(x: midPoint.x - off, y: midPoint.y), CGPoint(x: midPoint.x + off, y: midPoint.y)])
        drawText(context: context, at: CGPoint(x: 0, y: 0), text: text, offsize: 13)
        drawText(context: context, at: CGPoint(x: midPoint.x, y: midPoint.y), text: "\(size.width)x\(size.height)")
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return myImage?.jpegData(compressionQuality: 1) ?? Data()
        #else
            return Data()
        #endif
    }

    static func drawText(context: CGContext, at point: CGPoint, text: String, offsize: CGFloat = 20) {
        #if canImport(UIKit)
        UIGraphicsPushContext(context)
        let font = UIFont.systemFont(ofSize: offsize)
        let string = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.backgroundColor: UIColor.black
        ])
        string.draw(at: point)
        UIGraphicsPopContext()
        #endif
    }
}
