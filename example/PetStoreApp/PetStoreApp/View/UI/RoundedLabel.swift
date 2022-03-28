import SwiftUI

struct RoundedLabel: View {
    let text: String?
    let footer: String?
    var body: some View {
        VStack {
            VStack {
                Text(text ?? "").font(.title).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .padding(30)
            .background(.gray)
            .cornerRadius(20)
            Text(footer ?? "").font(.body)
        }
    }
}

struct RoundedLabel_Previews: PreviewProvider {
    static var previews: some View {
        RoundedLabel(text: "Tom", footer: "Name")
    }
}
