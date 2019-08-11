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
    let losAngelesTimeZone = TimeZone(identifier: "America/Los_Angeles")!
    var losAngeleTZ: TimeZoneType {
      return TimeZoneType.custom(losAngelesTimeZone.secondsFromGMT())
    }
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
    
    func test_02july2019() {
        let dateString = "02.07.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.phase == .newMoon, "must be New Moon")
        XCTAssert(info.moonModels.last?.age == 1, "day must be first")
    }

    func test_21october2019() {
        let dateString = "21.10.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.moonModels.last?.age == 23, "day must be 23")
    }
    
    func test_17july2019() {
        let dateString = "17.07.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
                XCTAssert(info.phase == .phase3, "must be \(DBMoonPhase.phase3)")
        XCTAssert(info.moonModels.last?.age == 16, "day must be 16")
    }
    
    func test_25august2019() {
        let dateString = "25.08.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.phase == .phase4, "must be \(DBMoonPhase.phase4)")
        XCTAssert(info.moonModels.last?.age == 25, "day must be 25")
    }
    
    func test_23august2019() {
        let dateString = "23.08.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.phase == .phase3, "must be \(DBMoonPhase.phase3.rawValue)")
        XCTAssert(info.moonModels.last?.age == 23, "day must be 23")
    }
    
    func test_23july2019() {
        let dateString = "23.07.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us"))?.startOfDay else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.phase == .phase3, "must be \(DBMoonPhase.phase3)")
        XCTAssert(info.moonModels.last?.age == 21, "day must be 21")
        XCTAssert(info.moonModels.last?.zodiacSign == .aries, "sign must be \(MoonZodiacSign.aries.rawValue)")
    }
    
    func test_18july2019() {
        let dateString = "18.07.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy"), timeZone: self.losAngeleTZ, locale: Locale(identifier: "En_us")) else {
            fatalError("cant get date from string!")
        }
        let info = manager.getInfo(date: date, city: city, timeZone: losAngeleTZ.timeZone)
        
        XCTAssert(info.phase == .phase3, "phase is \(info.phase) must be \(DBMoonPhase.phase3)")
        XCTAssert(info.moonModels.last?.age == 17, "day is \(info.moonModels.last?.age ?? 0) must be 17")
        XCTAssert(info.moonModels.last?.zodiacSign == .aquarius, "sign is \(info.moonModels.last?.zodiacSign.rawValue ?? "") must be \(MoonZodiacSign.aquarius)")
    }
}
