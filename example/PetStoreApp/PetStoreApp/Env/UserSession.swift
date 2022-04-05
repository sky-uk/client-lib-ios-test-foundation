import Foundation

 class UserSession: ObservableObject {
     @MainActor @Published var isUserLogged = false
}
