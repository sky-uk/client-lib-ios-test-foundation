import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var text: Text?

    var body: some View {
        VStack {
            text
            image?
                .resizable()
                .scaledToFit()
        }.frame(width: 400, height: 400, alignment: .center)
        .onAppear(perform: loadData)
    }

    func loadData() {
        loadImage()
        loadText()
    }

    func loadImage() {
        let url = URL(string: "http://localhost:8080/image")!
        URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data {
                            DispatchQueue.main.async {
                                let dd = ImageUtils.getImage(size: CGSize(width: 200,height: 200))
                                let nsImage = NSImage(data: dd)!
                                image = Image(nsImage: nsImage)
                            }
                        }
                    }.resume()
    }
    func loadText() {
        text = Text("Placeholder")
        let url = URL(string: "http://localhost:8080/message")!
        URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, data.count > 0 {

                            DispatchQueue.main.async {
                                text = Text(String(data: data, encoding: .utf8) ?? "")
                            }
                        }
                    }.resume()
    }



}

struct ImageUtils {
    static func getImage(size: CGSize) -> Data {
        let rect = CGRect(origin: CGPoint.zero, size: size)

        let context = CGContext(data: nil,
                           width: Int(size.width),
                           height: Int(size.height),
                           bitsPerComponent: 8,
                           bytesPerRow: 4 * Int(size.width),
                           space: CGColorSpaceCreateDeviceRGB(),
                           bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!

       // Draw square
        let path = CGPath(rect: rect, transform: nil)
        context.addPath(path)
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(20)
        context.setLineJoin(CGLineJoin.round)
        context.setLineCap(CGLineCap.round)

        let dashArray:[CGFloat] = [16, 32]
        context.setLineDash(phase: 0, lengths: dashArray)
        context.replacePathWithStrokedPath()

        context.setFillColor(NSColor.red.cgColor)
        context.fillPath()
        if let image = context.makeImage() {
            let img = NSImage(cgImage: image, size: size)
            return img.tiffRepresentation!
        } else {
            return Data()
        }

    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
