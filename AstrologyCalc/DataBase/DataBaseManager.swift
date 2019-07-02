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
        var countries = [DBCountryModel]()
        
        for i in 1...67 {
            if let country = self.getCountry(n: i) {
                countries.append(country)
            }
        }
        
        return countries
    }
    
    public func getCountry(n: Int) -> DBCountryModel? {
        if let path = Bundle.init(for: DataBaseManager.self).path(forResource: "db_\(n)", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let model = try decoder.decode(DBCountryModel.self, from: data)
                return model
            } catch {
                print(error)
            }
        }
        return nil
    }
}
