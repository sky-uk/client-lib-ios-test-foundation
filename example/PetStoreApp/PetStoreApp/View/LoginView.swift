import SwiftUI
import RxSwift

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var services: Services
    @State var username: String = ""
    @State var password: String = ""
    @State private var showingInvalidCredentialAlert = false
    let disposedBag = DisposeBag()

    var body: some View {
        VStack {
            Text("Please login").font(.largeTitle).padding(60)

            VStack(alignment: .leading) {
                Text("Username").font(.callout).bold()
                TextField("Username", text: $username).textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Password  ").font(.callout).bold()
                SecureField("Password", text: $password).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding()

            Button("Login") {
                Task {
                    do {
                        let response = try await services.user.loginUser(username: $username.wrappedValue,
                                                                         password: $password.wrappedValue).value
                        userSession.isUserLogged = (response.code == 200)
                        showingInvalidCredentialAlert = (response.code == 404)
                    } catch {
                        userSession.isUserLogged = false
                        showingInvalidCredentialAlert = false
                    }
                }
            }
            .font(.largeTitle)
            .alert("Invalid Credentials", isPresented: $showingInvalidCredentialAlert) {
                Button("OK", role: .cancel) { }
            }
        }.accessibilityIdentifier("xyz")
    }
}
