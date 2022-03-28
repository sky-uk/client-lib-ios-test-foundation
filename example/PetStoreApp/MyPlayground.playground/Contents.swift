import UIKit
import PetStoreSDK
import PetStoreSDKTests

var pet = Pet.mock()
print(pet)

pet = Pet.mock(status: Pet.Status.mock())
print(pet)

pet = Pet.mock(name: "Tom")
print(pet)

print("end")
