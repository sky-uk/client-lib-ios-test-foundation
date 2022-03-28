import SwiftUI
import PetStoreSDK
import ReactiveAPI

@main
struct PetStoreApp: App {
    var body: some Scene {
        WindowGroup {
            PetListView()
        }
    }
}
