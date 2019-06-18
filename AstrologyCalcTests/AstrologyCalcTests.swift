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
        
        self.date = Date(fromString: "23.05.2019", format: .custom("dd.MM.yyyy"))
        self.manager = MoonCalculatorManager(location: location)
    }
    
    override func tearDown() {
        
    }
    
    func testTimeInfo() {
        
        let info = manager.getInfo(date: self.date)
        let date = info.date.timeIntervalSince1970
        XCTAssert(date == self.date.timeIntervalSince1970, "date is failed, must be 23.05.2019")
    }
    
    func testMoonPhase() {
        
        let info = manager.getInfo(date: self.date)
        let phase = info.phase
        XCTAssert(phase == .newMoon, "phase is failed \(phase), must be \(MoonPhase.newMoon)")
    }
    
    func testLocation() {
        
        let info = manager.getInfo(date: self.date)
        let location = info.location
        XCTAssert(location == (self.location), "location is failed, must be \(CLLocation(latitude: 55.751244, longitude: 37.618423))")
    }
    
    func testTrajectory() {
        
        let info = manager.getInfo(date: self.date)
        let trajectory = info.trajectory
        XCTAssert(trajectory == MoonTrajectory.ascendent, "trajectory is failed, must be \(MoonTrajectory.ascendent)")
    }
    
    func testMoonModels() {
        
        let info = manager.getInfo(date: self.date)
        let models = info.moonModels
        
        XCTAssert(models.count == 3, "moonModels is failed, must be \(3)")
    }
    
    func test_23May() {
        
        let info = manager.getInfo(date: self.date)
        let model = info.moonModels[0]
        
        XCTAssert(model.age == 19, "moonModel is failed, must be \(19)")
        XCTAssert(model.zodiacSign == .sagittarius, "moonModel is failed sodiac is \(model.zodiacSign), must be \(MoonZodiacSign.sagittarius)")
        XCTAssert(model.moonRise == Date(fromString: "2019-05-22 21:20:55 +0000", format: .custom("yyyy-MM-dd HH:mm:ssZ")), "moonModel is failed, must be 2019-05-22 21:20:55 +0000")
        XCTAssert(model.moonSet == nil, "moonModel is failed, must be nil")
    }
    
    func test_21May() {
        let dateString = "21.05.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date)
        XCTAssert(info.moonModels.first?.age == 17, "first day age is failed, must be 17")
        XCTAssert(info.moonModels.last?.age == 18, "last day age is failed, must be 18")
        XCTAssert(info.moonModels.first?.moonSet?.day == "21", "moon set day is failed, must be 21")
        XCTAssert(info.moonModels.first?.moonSet?.toString(format: .custom("HH:mm")) == "23:29", "moon set time is failed, must be 23:29")
    }
}
