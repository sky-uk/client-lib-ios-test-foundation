import Foundation
import SwiftUI
import Combine

struct AsyncImage<Placeholder: View>: View {
    @State private var loader: ImageLoader
    private let placeholder: Placeholder

    init(url: URL, @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        _loader = State(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            return loader.image != nil ? Image(nsImage: loader.image!).resizable() as! Placeholder : placeholder
        }
    }
}

