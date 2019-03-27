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
    let timeInterval = TimeInterval(1551878863) // Wed, 06 Mar 2019 13:27:43 +0000
    var manager: MoonCalculatorManager!
    var date: Date!
    
    override func setUp() {
        
        self.date = Date(timeIntervalSince1970: timeInterval)
        self.manager = MoonCalculatorManager(location: location)
    }
    
    override func tearDown() {
        
    }
    
    func testTimeInfo() {
        
        let info = manager.getInfo(date: self.date)
        let time = info.date.timeIntervalSince1970
        XCTAssert(time == (self.timeInterval), "time is failed, must be \(1551878863)")
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
    
    func testModel1() {
        
        let info = manager.getInfo(date: self.date)
        let model = info.moonModels[0]
        
        XCTAssert(model.age == 29, "moonModel is failed, must be \(29)")
        XCTAssert(model.zodiacSign == .pisces, "moonModel is failed, must be \(MoonZodiacSign.pisces)")
        XCTAssert(model.moonRise == nil, "moonModel is failed, must be nil")
        XCTAssert(model.moonSet?.timeIntervalSince1970 == TimeInterval(1551846875), "moonModel is failed, must be \(1551846875) Wed, 06 Mar 2019 04:34:35 +0000")
    }
    
    func testModel2() {
        
        let info = manager.getInfo(date: self.date)
        let model = info.moonModels[1]
        
        XCTAssert(model.age == 30, "moonModel is failed, must be \(30)")
        XCTAssert(model.zodiacSign == .pisces, "moonModel is failed, must be \(MoonZodiacSign.pisces)")
        XCTAssert(model.moonRise?.timeIntervalSince1970 == TimeInterval(1551846875), "moonModel is failed, must be \(1551846875) Wed, 06 Mar 2019 04:34:35 +0000")
        XCTAssert(model.moonSet?.timeIntervalSince1970 == TimeInterval(1551883653), "moonModel is failed, must be \(1551883653) Wed, 06 Mar 2019 14:47:33 +0000")
    }
    
    func testModel3() {
        
        let info = manager.getInfo(date: self.date)
        let model = info.moonModels[2]
        
        XCTAssert(model.age == 1, "moonModel is failed, must be \(1)")
        XCTAssert(model.zodiacSign == .pisces, "moonModel is failed, must be \(MoonZodiacSign.pisces)")
        XCTAssert(model.moonRise?.timeIntervalSince1970 == TimeInterval(1551883653), "moonModel is failed, must be \(1551883653) Wed, 06 Mar 2019 14:47:33 +0000")
        XCTAssert(model.moonSet == nil, "moonModel is failed, must be nil")
    }

    
}
