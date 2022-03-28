import SwiftUI
import PetStoreSDK

struct PetDetailView: View {

    let petId: Int

    @State var isErrorAlertVisible = false
    @EnvironmentObject var services: Services
    @State var pet: Pet?
    @State var isFoodViewVisible = false
    var body: some View {
        VStack {
            HStack {
                RoundedLabel(text: pet?.name, footer: "Name")
                RoundedLabel(text: pet?.status?.description, footer: "Status")
            }.padding()
            Spacer()
            Button("Suggest food", action: {
                isFoodViewVisible = true
            }).font(.largeTitle)
            Spacer()
                .task {
                    do {
                        pet = try await services.pet.getPetById(petId: petId).value
                    } catch {
                        isErrorAlertVisible = true
                    }
                }
        }
        /* FOOD ADDITIONS START
        .sheet(isPresented: $isFoodViewVisible) {
            FoodView(petId: petId)
        }
        FOOD ADDITIONS END */
        .alert("Network Error", isPresented: $isErrorAlertVisible) {
            Button("OK") { isErrorAlertVisible = true }
        }
    }
}
