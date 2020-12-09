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
        let url = URL(string: "http://127.0.0.1:8080/image")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, data.count > 0 {
                DispatchQueue.main.async {
                    let uiImage = UIImage(data: data)!
                    image = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }
    func loadText() {
        text = Text("Placeholder")
        let url = URL(string: "http://127.0.0.1:8080/message")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, data.count > 0 {
                DispatchQueue.main.async {
                    text = Text(String(data: data, encoding: .utf8) ?? "")
                }
            }
        }.resume()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
