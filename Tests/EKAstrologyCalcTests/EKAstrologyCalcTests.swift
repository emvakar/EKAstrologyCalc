import XCTest
import CoreLocation
import DevHelper

@testable import EKAstrologyCalc

final class EKAstrologyCalcTests: XCTestCase {
    
    func test_case_1() {

        let location = CLLocation(latitude: 55.751244, longitude: 37.618423) // Moscow location
        let manager = EKMoonCalculatorManager(location: location)

        guard let date = Date(fromString: "2020-06-21T09:18+03:00", format: .isoDateTime) else { return }
        let astroModel = manager.getInfo(date: date)
        print(astroModel)
    }

    static var allTests = [
        ("test_case_1", test_case_1),
    ]
}
