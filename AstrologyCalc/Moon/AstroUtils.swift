//
//  AstroUtils.swift
//  AstrologyCalc
//
//  Created by  Yuri on 03/04/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

class AstroUtils {

    public static func isLeap(year: Int) -> Bool {
        if year < 1582 && year % 4 == 0 {
            return true
        }

        if year % 100 == 0 && (year / 100) % 4 != 0 {
            return false
        }

        if year % 4 == 0 {
            return true
        }

        return false
    }

    /// get day number in year
    static func dayOfYear(year: Int, month: Int, day: Int) -> Int {
        let K = AstroUtils.isLeap(year: year) ? 1 : 2
        return ((275 * month) / 9) - K * ((month + 9) / 12) + day - 30
    }

    /// Converts date to year with fractions
    static func dayToYear(_ date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)

        guard let year = components.year, let month = components.month, let day = components.day else {
            fatalError("Can't unwrap date components")
        }

        let dayOfYear = AstroUtils.dayOfYear(
            year: year,
            month: month,
            day: day
        )

        return Double(year) + Double(dayOfYear) / 365.2425;
    }

    // returns julian date timestamp from date by gregorian calendar
    static func jdFromDate(date: Date) -> Double {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
    }

    // returns gregorian date from julian calendar date timestamp
    static func gregorianDateFrom(julianTime: Double) -> Date {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return Date(timeIntervalSince1970: (julianTime - JD_JAN_1_1970_0000GMT) * 86400)
    }

    static func to360(_ angle: Double) -> Double {
        return angle.truncatingRemainder(dividingBy: 360.0) + (angle < 0 ? 360 : 0)
    }

    // convert angle to radians
    static func toRadians(_ angle: Double) -> Double {
        return angle * .pi / 180
    }

}
