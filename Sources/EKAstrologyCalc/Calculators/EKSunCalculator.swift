//
//  EKSunCalculator.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 02.06.2021.
//  Copyright © 2021 Emil Karimov. All rights reserved.
//

import Foundation
import CoreLocation

public struct EKSunCalculator {
    
    /// The coordinate that is used for the calculation
    let coordinate: CLLocationCoordinate2D
    
    /// The date to generate sunrise / sunset times for
    fileprivate(set) var date: Date
    
    fileprivate(set) var solar: EKRiseSetModel?
    
    // MARK: Init
    
    public init?(date: Date = Date(), location: CLLocation) {
        self.date = date

        guard CLLocationCoordinate2DIsValid(location.coordinate) else {
            return nil
        }
        
        self.coordinate = location.coordinate
        
        // Fill this SunCalculator object with relevant data
        calculate()
    }
    
    // MARK: - Public functions
    
    /// Sets all of the Solar object's sunrise / sunset variables, if possible.
    /// - Note: Can return `nil` objects if sunrise / sunset does not occur on that day.
    public mutating func calculate() {

        let solar = EKRiseSetModel(
            rise: calculate(.sunrise, for: date, and: .official),
            set: calculate(.sunset, for: date, and: .official)
        )
        self.solar = solar
    }

    public func getSolar() -> EKRiseSetModel {
        let solar = EKRiseSetModel(
            rise: calculate(.sunrise, for: date, and: .official),
            set: calculate(.sunset, for: date, and: .official)
            )
        return solar
    }
    
    // MARK: - Private functions
    
    fileprivate enum SunriseSunset {
        case sunrise
        case sunset
    }
    
    /// Used for generating several of the possible sunrise / sunset times
    fileprivate enum Zenith: Double {
        case official = 90.83
        case civil = 96
        case nautical = 102
        case astronimical = 108
    }
    
    fileprivate func calculate(_ sunriseSunset: SunriseSunset, for date: Date, and zenith: Zenith) -> Date? {
        guard let utcTimezone = TimeZone(identifier: "UTC") else { return nil }
        
        // Get the day of the year
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimezone
        guard let dayInt = calendar.ordinality(of: .day, in: .year, for: date) else { return nil }
        let day = Double(dayInt)
        
        // Convert longitude to hour value and calculate an approx. time
        let lngHour = coordinate.longitude / 15
        
        let hourTime: Double = sunriseSunset == .sunrise ? 6 : 18
        let t = day + ((hourTime - lngHour) / 24)
        
        // Calculate the suns mean anomaly
        let M = (0.9856 * t) - 3.289
        
        // Calculate the sun's true longitude
        let subexpression1 = 1.916 * sin(M.degreesToRadians)
        let subexpression2 = 0.020 * sin(2 * M.degreesToRadians)
        var L = M + subexpression1 + subexpression2 + 282.634
        
        // Normalise L into [0, 360] range
        L = normalise(L, withMaximum: 360)
        
        // Calculate the Sun's right ascension
        var RA = atan(0.91764 * tan(L.degreesToRadians)).radiansToDegrees
        
        // Normalise RA into [0, 360] range
        RA = normalise(RA, withMaximum: 360)
        
        // Right ascension value needs to be in the same quadrant as L...
        let Lquadrant = floor(L / 90) * 90
        let RAquadrant = floor(RA / 90) * 90
        RA = RA + (Lquadrant - RAquadrant)
        
        // Convert RA into hours
        RA = RA / 15
        
        // Calculate Sun's declination
        let sinDec = 0.39782 * sin(L.degreesToRadians)
        let cosDec = cos(asin(sinDec))
        
        // Calculate the Sun's local hour angle
        let cosH = (cos(zenith.rawValue.degreesToRadians) - (sinDec * sin(coordinate.latitude.degreesToRadians))) / (cosDec * cos(coordinate.latitude.degreesToRadians))
        
        // No sunrise
        guard cosH < 1 else {
            return nil
        }
        
        // No sunset
        guard cosH > -1 else {
            return nil
        }
        
        // Finish calculating H and convert into hours
        let tempH = sunriseSunset == .sunrise ? 360 - acos(cosH).radiansToDegrees : acos(cosH).radiansToDegrees
        let H = tempH / 15.0
        
        // Calculate local mean time of rising
        let T = H + RA - (0.06571 * t) - 6.622
        
        // Adjust time back to UTC
        var UT = T - lngHour
        
        // Normalise UT into [0, 24] range
        UT = normalise(UT, withMaximum: 24)
        
        // Calculate all of the sunrise's / sunset's date components
        let hour = floor(UT)
        let minute = floor((UT - hour) * 60.0)
        let second = (((UT - hour) * 60) - minute) * 60.0
        
        let shouldBeYesterday = lngHour > 0 && UT > 12 && sunriseSunset == .sunrise
        let shouldBeTomorrow = lngHour < 0 && UT < 12 && sunriseSunset == .sunset
        
        let setDate: Date
        if shouldBeYesterday {
            setDate = Date(timeInterval: -(60 * 60 * 24), since: date)
        } else if shouldBeTomorrow {
            setDate = Date(timeInterval: (60 * 60 * 24), since: date)
        } else {
            setDate = date
        }
        
        var components = calendar.dateComponents([.day, .month, .year], from: setDate)
        components.hour = Int(hour)
        components.minute = Int(minute)
        components.second = Int(second)
        
        calendar.timeZone = utcTimezone
        return calendar.date(from: components)
    }
    
    /// Normalises a value between 0 and `maximum`, by adding or subtracting `maximum`
    fileprivate func normalise(_ value: Double, withMaximum maximum: Double) -> Double {
        var value = value
        
        if value < 0 {
            value += maximum
        }
        
        if value > maximum {
            value -= maximum
        }
        
        return value
    }
    
}

extension EKSunCalculator {
    
    /// Whether the location specified by the `latitude` and `longitude` is in daytime on `date`
    /// - Complexity: O(1)
    public var isDaytime: Bool {
        guard
            let sunrise = solar?.rise,
            let sunset = solar?.set
            else {
                return false
        }
        
        let beginningOfDay = sunrise.timeIntervalSince1970
        let endOfDay = sunset.timeIntervalSince1970
        let currentTime = self.date.timeIntervalSince1970
        
        let isSunriseOrLater = currentTime >= beginningOfDay
        let isBeforeSunset = currentTime < endOfDay
        
        return isSunriseOrLater && isBeforeSunset
    }
    
    /// Whether the location specified by the `latitude` and `longitude` is in nighttime on `date`
    /// - Complexity: O(1)
    public var isNighttime: Bool {
        return !isDaytime
    }
    
}

// MARK: - Helper extensions

private extension Double {
    var degreesToRadians: Double {
        return Double(self) * (Double.pi / 180.0)
    }
    
    var radiansToDegrees: Double {
        return (Double(self) * 180.0) / Double.pi
    }
}
