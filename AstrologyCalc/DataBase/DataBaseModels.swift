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
    
    enum CodingKeys: String, CodingKey {
        
        case moonDays = "moonDays"
        case cityName = "cityName"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        moonDays = try values.decode([DBMoonDayModel].self, forKey: .moonDays)
        cityName = try values.decode(String.self, forKey: .cityName)
    }
    
    public init(cityName: String, moonDays: [DBMoonDayModel]) {
        self.cityName = cityName
        self.moonDays = moonDays
    }
}

public struct DBMoonDayModel : Codable {
    
    public let age: Int
    public let date: Date?
    public let signDate: String
    public let sign: String
    
    enum CodingKeys: String, CodingKey {
        
        case age = "age"
        case date = "date"
        case signDate = "signDate"
        case sign = "sign"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        age = try values.decode(Int.self, forKey: .age)
        let stringDate = try values.decode(String.self, forKey: .date)
        date = stringDate.toDate
        signDate = try values.decode(String.self, forKey: .signDate)
        sign = try values.decode(String.self, forKey: .sign)
    }
    
    public init(age: Int, date: Date?, signDate: String, sign: String) {
        self.age = age
        self.date = date
        self.signDate = signDate
        self.sign = sign
    }
}
