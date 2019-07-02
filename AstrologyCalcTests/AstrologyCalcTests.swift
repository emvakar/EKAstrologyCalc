//
//  AstrologyCalcTests.swift
//  AstrologyCalcTests
//
//  Created by Emil Karimov on 27/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import XCTest
import CoreLocation
import DevHelper
@testable import AstrologyCalc

class AstrologyCalcTests: XCTestCase {

    let location = CLLocation(latitude: 55.751244, longitude: 37.618423)
    
    var manager: MoonCalculatorManager!
    var date: Date!
    let losAngeleTZ = TimeZoneType.custom(3600*(-7))
    let city = DataBaseManager().getCountry(n: 19)?.cities.first(where: { $0.cityName.contains("Лос-Ан") })
    
    override func setUp() {
        self.date = Date(fromString: "02.07.2019", format: .custom("dd.MM.yyyy"), timeZone: losAngeleTZ, locale: Locale.init(identifier: "En_us"))
        self.manager = MoonCalculatorManager(location: location)
    }
    
    override func tearDown() {
        
    }
    
    func test_timeInfo() {
        
        let info = manager.getInfo(date: self.date, city: city, timeZone: losAngeleTZ.timeZone)
        let date = info.date.timeIntervalSince1970
        XCTAssert(date == self.date.timeIntervalSince1970, "date is failed, must be 23.05.2019")
    }
    
    func test_moonPhase() {
        
        let info = manager.getInfo(date: self.date, city: city, timeZone: losAngeleTZ.timeZone)
        let phase = info.phase
        XCTAssert(phase == .newMoon, "phase is failed \(phase), must be \(DBMoonPhase.newMoon)")
    }
    
    func test_location() {
        
        let info = manager.getInfo(date: self.date, city: city, timeZone: losAngeleTZ.timeZone)
        let location = info.location
        XCTAssert(location == (self.location), "location is failed, must be \(CLLocation(latitude: 55.751244, longitude: 37.618423))")
    }
    
    func test_trajectory() {
        
        let info = manager.getInfo(date: self.date, city: city, timeZone: losAngeleTZ.timeZone)
        let trajectory = info.trajectory
        XCTAssert(trajectory == MoonTrajectory.ascendent, "trajectory is failed, must be \(MoonTrajectory.ascendent)")
    }
    
    func test_moonModels() {
        
        let info = manager.getInfo(date: self.date, city: city, timeZone: losAngeleTZ.timeZone)
        let models = info.moonModels.filter({ ($0.moonRise?.isSameDate(self.date, timeZone: self.losAngeleTZ.timeZone) ?? false) || ($0.moonSet?.isSameDate(self.date, timeZone: self.losAngeleTZ.timeZone) ?? false) })
        
        XCTAssert(models.count == 3, "moonModels is failed, must be \(3)")
    }
    
    func test_02july() {
        let dateString = "02.07.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.phase == .newMoon, "must be New Moon")
        XCTAssert(info.moonModels.last?.age == 1, "day must be first")
    }

}
