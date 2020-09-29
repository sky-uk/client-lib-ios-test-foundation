import UIKit
import Foundation

extension UITestHttpServerBuilder {
    // MARK: Image utilities
    static func drawOnImage(text: String, properties: ImageProperties? = nil) -> UIImage? {
        let size = properties?.size ?? CGSize(width: 500, height: 500)
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
        return myImage
    }

    static func drawText(context: CGContext, at point: CGPoint, text: String, offsize: CGFloat = 20) {
        UIGraphicsPushContext(context)
        let font = UIFont.systemFont(ofSize: offsize)
        let string = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.backgroundColor: UIColor.black
        ])
        string.draw(at: point)
        UIGraphicsPopContext()
    }

}