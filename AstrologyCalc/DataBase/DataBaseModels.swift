//
//  DataBaseModels.swift
//  AstrologyCalc
//
//  Created by Егор on 28/06/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

public struct DBCountryModel: Codable {
    
    public let countryName: String
    public let cities: [DBCityModel]
    
    enum CodingKeys: String, CodingKey {
        case countryName = "countryName"
        case cities = "cities"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countryName = try values.decode(String.self, forKey: .countryName)
        cities = try values.decode([DBCityModel].self, forKey: .cities)
    }
    
    public init(countryName: String, cities: [DBCityModel]) {
        self.countryName = countryName
        self.cities = cities
    }
}

public struct DBCityModel: Codable {
    
    public let cityName: String
    public let moonDays: [DBMoonDayModel]
    public let timeZone: Int
    
    enum CodingKeys: String, CodingKey {
        
        case moonDays = "moonDays"
        case cityName = "cityName"
        case timeZone = "timeZone"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        moonDays = try values.decode([DBMoonDayModel].self, forKey: .moonDays)
        cityName = try values.decode(String.self, forKey: .cityName)
        timeZone = try values.decode(Int.self, forKey: .timeZone)
    }
    
    public init(cityName: String, moonDays: [DBMoonDayModel], timeZone: Int) {
        self.cityName = cityName
        self.moonDays = moonDays
        self.timeZone = timeZone
    }
}

public enum DBMoonPhase: String, Codable {
    case newMoon
    case phase1
    case phase2
    case fullMoon
    case phase3
    case phase4
    
    public var priority: Int {
        switch self {
        case .newMoon:
            return 1
        case .phase1:
            return 2
        case .phase2:
            return 3
        case .fullMoon:
            return 4
        case .phase3:
            return 5
        case .phase4:
            return 6
        }
    }
}

public struct DBMoonDayModel: Codable {
    
    public let age: Int
    public let timeZone: Int
    public let moonStartDate: Date?
    public let signDate: String
    public let sign: String
    public var moonPhase: DBMoonPhase?
    public var moonPhaseDate: Date?
    
    enum CodingKeys: String, CodingKey {
        
        case age = "age"
        case timeZone = "timeZone"
        case moonStartDate = "date"
        case signDate = "signDate"
        case sign = "sign"
        case moonPhase = "moonPhase"
        case moonPhaseDate = "moonPhaseDate"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        age = try values.decode(Int.self, forKey: .age)
        timeZone = try values.decode(Int.self, forKey: .timeZone)
        let stringDate = try values.decode(String.self, forKey: .moonStartDate)
        moonStartDate = stringDate.toDate
        signDate = try values.decode(String.self, forKey: .signDate)
        sign = try values.decode(String.self, forKey: .sign)
        if let phase = try values.decodeIfPresent(String.self, forKey: .moonPhase) {
            moonPhase = DBMoonPhase(rawValue: phase)
        }
        if let stringDatePhase = try values.decodeIfPresent(String.self, forKey: .moonPhaseDate) {
            moonPhaseDate = stringDatePhase.toDate
        }
    }
    
    public init(age: Int, timeZone: Int, date: Date?, signDate: String, sign: String, moonPhase: DBMoonPhase?, moonPhaseDate: Date?) {
        self.age = age
        self.timeZone = timeZone
        self.moonStartDate = date
        self.signDate = signDate
        self.sign = sign
        self.moonPhase = moonPhase
        self.moonPhaseDate = moonPhaseDate
    }
}
