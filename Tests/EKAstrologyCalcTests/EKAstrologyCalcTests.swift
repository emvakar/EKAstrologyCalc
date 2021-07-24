import XCTest
import CoreLocation
import ESDateHelper

@testable import EKAstrologyCalc

final class EKAstrologyCalcTests: XCTestCase {
    
    static var allTests = [
        ("test_case_01", test_case_01),
        ("test_case_02", test_case_02),
        ("test_case_03", test_case_03),
        ("test_case_04", test_case_04),
        ("test_case_05", test_case_05),
        ("test_case_06", test_case_06),
        ("test_case_07", test_case_07),
    ]
    
    private let testedDate = Date(fromString: "2021-07-28T04:18+03:00", format: .isoDateTime)!
    private let location = CLLocation(latitude: 55.751244, longitude: 37.618423) // Moscow location
    private lazy var manager = EKAstrologyCalc(location: location)
    private lazy var astroModel = manager.getInfo(date: testedDate)
    
    func test_case_01() {
        XCTAssertTrue(astroModel.date == testedDate)
    }
    
    func test_case_02() {
        let willBeDate = Date(fromString: "2021-07-27T19:32:27+00:00", format: .isoDateTimeSec)!
        XCTAssertTrue(astroModel.moonModels[0].begin == willBeDate)
    }
    
    func test_case_03() {
        XCTAssertTrue(astroModel.moonModels[0].sign ==  .aries)
    }
    
    func test_case_04() {
        XCTAssertTrue(astroModel.phase == .waningGibbous)
    }

    func test_case_05() {
        XCTAssertTrue(astroModel.illumination != nil)
    }
    
    func test_case_06() {
        var infos = [EKAstrologyModel]()
        guard let startYear = Date().startOfYear?.adjust(.hour, offset: 3) else { XCTFail("date must be"); return }
        for i in 0..<364 {
            let info = manager.getInfo(date: startYear.adjust(.day, offset: i))
            infos.append(info)
        }
    }

    func test_case_07() {

        /*  date     m rise   m set   s rise   s set
         27-7-2021    22:32    8:13    4:26    20:45
         28-7-2021    22:42    9:35    4:27    20:43
         29-7-2021    22:52    10:52   4:29    20:41
         30-7-2021    23:02    12:08   4:31    20:39

         // for Moscow July 2021
         // for testing data http://www.mojgorod.ru/cgi-bin/moonsun.cgi?OKATO=45
         */

        let moonRiseWillBe = Date(fromString: "2021-07-28T22:42:26+03:00", format: .isoDateTimeSec)!
        let moonSetWillBe = Date(fromString: "2021-07-28T09:34:45+03:00", format: .isoDateTimeSec)!

        let sunRiseWillBe = Date(fromString: "2021-07-28T04:26:32+03:00", format: .isoDateTimeSec)!
        let sunSetWillBe = Date(fromString: "2021-07-28T20:44:30+03:00", format: .isoDateTimeSec)!

        let randomFailedDate = Date(fromString: "2022-07-28T20:44:30+03:00", format: .isoDateTimeSec)!

        XCTAssertTrue(astroModel.moonModel != nil)
        XCTAssertTrue(astroModel.moonModel?.rise == moonRiseWillBe)
        XCTAssertTrue(astroModel.moonModel?.set == moonSetWillBe)

        XCTAssertTrue(astroModel.sunModel?.rise == sunRiseWillBe)
        XCTAssertTrue(astroModel.sunModel?.set == sunSetWillBe)

        XCTAssertFalse(astroModel.sunModel?.rise == randomFailedDate)

    }
}
