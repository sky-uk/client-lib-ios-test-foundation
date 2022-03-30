import SwiftUI
import PetStoreSDK
import RxSwift

struct PetListView: View {
    // TODO: https://stackoverflow.com/questions/71396296/how-do-i-fix-expression-requiring-global-actor-mainactor-cannot-appear-in-def
    @StateObject var userSession = UserSession()
    @StateObject var services = Services(baseUrl: Urls.baseUrl())
    @State var pets: [Pet] = []

    var body: some View {
        NavigationView {
            List(pets, id: \.self) { pet in
                NavigationLink(destination: PetDetailView(petId: pet._id)) {
                    Text(pet.name)
                }
            }.navigationTitle("Pet List")
        }
        .sheet(isPresented: !$userSession.isUserLogged) { LoginView() }
        .task {
            do {
                pets = try await services.pet.findPetsByStatus(status: [Pet.Status.available.rawValue]).value
            } catch {
                print("TODO handle error")
            }
        }
        .environmentObject(userSession)
        .environmentObject(services)
    }
}
