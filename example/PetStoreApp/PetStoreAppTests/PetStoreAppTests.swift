import XCTest
import SkyTestFoundation
import RxBlocking
import PetStoreSDK
@testable import PetStoreApp

class PetStoreAppTests: SkyUnitTestCase {

    var sut: Services?

    override func setUp() {
        super.setUp()
        sut = Services(baseUrl: Urls.baseUrl().replaceHostnameWithLocalhostIfUITestIsRunning())
    }

    func test() async throws {
        do {
            let pets = try await sut!.pet.findPetsByStatus(status: [Pet.Status.available.rawValue]).value
            assertNotNull(pets)
        } catch {
            print("not found")
        }
    }
}
