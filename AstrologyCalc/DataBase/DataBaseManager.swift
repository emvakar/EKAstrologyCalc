//
//  DataBaseManager.swift
//  AstrologyCalc
//
//  Created by Егор on 28/06/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

public class DataBaseManager {
    
    public init() {}
    
    public func makeCountriesFromJSON() -> [DBCountryModel] {
        if let path = Bundle.init(identifier: "site.karimov.AstrologyCalc")?.path(forResource: "DataBase", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let models = try decoder.decode([DBCountryModel].self, from: data)
                return models
            } catch {
                print(error)
            }
        }
        
        return []
    }
}
