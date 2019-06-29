//
//  AstrologyCalcTests.swift
//  AstrologyCalcTests
//
//  Created by Emil Karimov on 27/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import XCTest
import CoreLocation
@testable import AstrologyCalc

class AstrologyCalcTests: XCTestCase {

    let location = CLLocation(latitude: 55.751244, longitude: 37.618423)
    
    var manager: MoonCalculatorManager!
    var date: Date!
    
    override func setUp() {
        
        self.date = Date(fromString: "22.05.2019", format: .custom("dd.MM.yyyy"))
        self.manager = MoonCalculatorManager(location: location)
    }
    
    override func tearDown() {
        
    }
    
    func testTimeInfo() {
        
        let info = manager.getInfo(date: self.date, city: nil)
        let date = info.date.timeIntervalSince1970
        XCTAssert(date == self.date.timeIntervalSince1970, "date is failed, must be 23.05.2019")
    }
    
    func testMoonPhase() {
        
        let info = manager.getInfo(date: self.date, city: nil)
        let phase = info.phase
        XCTAssert(phase == .waningGibbous, "phase is failed \(phase), must be \(MoonPhase.waningGibbous)")
    }
    
    func testLocation() {
        
        let info = manager.getInfo(date: self.date, city: nil)
        let location = info.location
        XCTAssert(location == (self.location), "location is failed, must be \(CLLocation(latitude: 55.751244, longitude: 37.618423))")
    }
    
    func testTrajectory() {
        
        let info = manager.getInfo(date: self.date, city: nil)
        let trajectory = info.trajectory
        XCTAssert(trajectory == MoonTrajectory.descendent, "trajectory is failed, must be \(MoonTrajectory.descendent)")
    }
    
    func testMoonModels() {
        
        let info = manager.getInfo(date: self.date, city: nil)
        let models = info.moonModels
        
        XCTAssert(models.count == 1, "moonModels is failed, must be \(1)")
    }
    
    func test_23May() {
        let dateString = "23.05.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: nil)
        let model19 = info.moonModels[1]
        
        XCTAssert(model19.age == 19, "moonModel is failed, must be \(19)")
        let signDate = Date(fromString: "2019-05-23 17:51:00 +0000", format: .custom("yyyy-MM-dd HH:mm:ssZ")) ?? Date()
        XCTAssert((model19.zodiacSignDate ?? Date()).isSameDate(signDate), "moonModel is failed sodiac Date is \(model19.zodiacSignDate?.toString() ?? ""), must be \(signDate)")
        XCTAssert(model19.zodiacSign == .aquarius, "moonModel is failed sodiac is \(model19.zodiacSign), must be \(MoonZodiacSign.aquarius)")
        let moonRise = (Date(fromString: "2019-05-22 21:20:00 +0000", format: .custom("yyyy-MM-dd HH:mm:ssZ")) ?? Date())
        XCTAssert(model19.moonRise == moonRise, "moonModel is failed, must be 2019-05-23 21:20:00 +0000")
//        XCTAssert(model19.moonSet == nil, "moonModel is failed, must be nil")
    }
    
    func test_21May() {
        let dateString = "21.05.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: nil)
        XCTAssert(info.moonModels.first?.age == 17, "first day age is failed, must be 17")
        XCTAssert(info.moonModels.last?.age == 18, "last day age is failed, must be 18")
        XCTAssert(info.moonModels.first?.moonSet?.day == "21", "moon set day is failed, must be 21")
        XCTAssert(info.moonModels.first?.moonSet?.toString(format: .custom("HH:mm")) == "23:29", "moon set time is failed, must be 23:29")
    }
}
