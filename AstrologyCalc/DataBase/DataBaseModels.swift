//
//  DataBaseModels.swift
//  AstrologyCalc
//
//  Created by Егор on 28/06/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

public struct DBCountryModel: Codable {
    
    let countryName: String
    let cities: [DBCityModel]
    
    enum CodingKeys: String, CodingKey {
        case countryName = "countryName"
        case cities = "cities"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countryName = try values.decode(String.self, forKey: .countryName)
        cities = try values.decode([DBCityModel].self, forKey: .cities)
    }
}

public struct DBCityModel: Codable {
    
    let cityName: String
    let moonDays: [DBMoonDayModel]
    
    enum CodingKeys: String, CodingKey {
        
        case moonDays = "moonDays"
        case cityName = "cityName"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        moonDays = try values.decode([DBMoonDayModel].self, forKey: .moonDays)
        cityName = try values.decode(String.self, forKey: .cityName)
    }
}

public struct DBMoonDayModel : Codable {
    
    let age: Int
    let date: String
    let signDate: String
    let sign: String
    
    enum CodingKeys: String, CodingKey {
        
        case age = "age"
        case date = "date"
        case signDate = "signDate"
        case sign = "sign"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        age = try values.decode(Int.self, forKey: .age)
        date = try values.decode(String.self, forKey: .date)
        signDate = try values.decode(String.self, forKey: .signDate)
        sign = try values.decode(String.self, forKey: .sign)
    }
}
