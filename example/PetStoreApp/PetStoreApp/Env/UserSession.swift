import Foundation

@MainActor class UserSession: ObservableObject {
    @Published var isUserLogged = false
}
