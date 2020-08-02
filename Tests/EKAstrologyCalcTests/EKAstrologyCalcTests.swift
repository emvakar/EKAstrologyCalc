import XCTest
import CoreLocation
import ESDateHelper

@testable import EKAstrologyCalc

final class EKAstrologyCalcTests: XCTestCase {
    
    static var allTests = [
        ("test_case_1", test_case_1),
        ("test_case_2", test_case_2),
        ("test_case_3", test_case_3),
        ("test_case_4", test_case_4),
        ("test_case_5", test_case_5),
    ]
    
    private let testedDate =  Date(fromString: "2020-07-20T04:18+03:00", format: .isoDateTime)!
    private let location = CLLocation(latitude: 55.751244, longitude: 37.618423) // Moscow location
    private lazy var manager = EKAstrologyCalc(location: location)
    private lazy var astroModel = manager.getInfo(date: testedDate)
    
    func test_case_1() {
        XCTAssertTrue(astroModel.date == testedDate)
    }
    
    func test_case_2() {
        print("tested date :", testedDate)
        astroModel.moonModels.enumerated().forEach {
            print("\($0.offset) model begin :", $0.element.begin ?? Date())
            print("\($0.offset) model finish:", $0.element.finish ?? Date())
            print("\($0.offset) model sign  :", $0.element.sign)
            print("\($0.offset) model age   :", $0.element.age)
        }
        XCTAssertTrue(astroModel.moonModels[0].age == 29)
    }
    
    func test_case_3() {
        let willBeDate = Date(fromString: "2020-07-20T00:17:36+00:00", format: .isoDateTimeSec)!
        XCTAssertTrue(astroModel.moonModels[0].begin == willBeDate)
    }
    
    func test_case_4() {
        XCTAssertTrue(astroModel.moonModels[0].sign ==  .cancer)
    }
    
    func test_case_5() {
        XCTAssertTrue(astroModel.phase == .newMoon)
    }

}
