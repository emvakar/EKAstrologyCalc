//
//  DataBaseManager.swift
//  AstrologyCalc
//
//  Created by Егор on 28/06/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

public struct LCityModel: Codable {
    public var ruName: String
    public var enName: String
    public var lat: Double
    public var lng: Double

    public func getDict() -> [String: Any] {
        return ["ruName": self.ruName, "enName": self.enName, "lat": self.lat, "lng": self.lng]
    }
}

struct VLCityModel {
    let ruName: String
    let enName: String
    let lat: Double
    let lng: Double
    var distance: Double

    init(_ model: LCityModel, dist: Double) {
        self.ruName = model.ruName
        self.enName = model.enName
        self.lat = model.lat
        self.lng = model.lng
        self.distance = dist
    }
}

public class DataBaseManager {

    public init() { }

    public func makeCountriesFromJSON() -> [DBCountryModel] {
        var countries = [DBCountryModel]()

        for i in 0...67 {
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

    public func getCoordinate(for city: String) -> LCityModel? {
        if let path = Bundle.init(for: DataBaseManager.self).path(forResource: "cities_coordinates", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let model = try decoder.decode([LCityModel].self, from: data).first(where: { $0.ruName == city })
                return model
            } catch {
                print(error)
            }
        }
        return nil
    }

    struct NearestModel {
        var xDistance: Int = 0
        var yDisatance: Double = 0
        var city: String = ""
    }

    public func getCityByCoordinates(lat: Double, lng: Double) -> LCityModel? {
        if let path = Bundle.init(for: DataBaseManager.self).path(forResource: "cities_coordinates", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let models = try decoder.decode([LCityModel].self, from: data)

                var cModels = [VLCityModel]()

                for model in models {

                    let a = abs(model.lat - lat)
                    let b = abs(model.lng - lng)
                    let c = a.squareRoot() + b.squareRoot()
                    let m = VLCityModel(model, dist: c)
                    cModels.append(m)
                }

                let r = cModels.sorted(by: { $0.distance < $1.distance }).first
                if let r = r {
                    let rm = LCityModel(ruName: r.ruName, enName: r.enName, lat: r.lat, lng: r.lng)
                    return rm
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
}
