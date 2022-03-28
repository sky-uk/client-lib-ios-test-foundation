import SwiftUI
import PetStoreSDK

/* FOOD ADDITIONS START
struct FoodView: View {
    let petId: Int
    
    @EnvironmentObject var services: Services
    @State var food: Food?
    
    var body: some View {
        VStack {
            AsyncImage(
                url: URL(string: "http://127.0.0.1:8080/v2/food/11/image"),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                },
                placeholder: {
                    ProgressView()
                }
            )
            HStack {
                RoundedLabel(text: food?.name, footer: "Name")
                RoundedLabel(text: food?.price.formatted(), footer: "Price")
            }.padding()
            
        }.task {
            do {
                food = try await services.food.foodSuggestions(petId: petId).value.first
            } catch {
                food = nil
            }
        }
    }
}
FOOD ADDITIONS END */
