//
//  Date+Extension.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 21/05/2019.
//

import Foundation
import UIKit
import DevHelper



extension Date {
    
    public var timeZone: Int {
        return UserDefaults.standard.integer(forKey: "timeZone")
    }
    
    public var addDay: Date? {
        var components = DateComponents()
        components.day = 1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: self)
    }
    
    public func startOfMonth() -> Date {
        return Calendar(identifier: .gregorian).date(from: Calendar(identifier: .gregorian).dateComponents([.year, .month], from: Calendar(identifier: .gregorian).startOfDay(for: self)))!
    }
    
    public func endOfMonth() -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    public func toHHmm(timeZone: TimeZone) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    public func day(timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self)
    }
    
    public func month(timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }
    public func year(timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    public func startOfYear(timeZone: TimeZone) -> Date? {
        
        var userCalendar = Calendar(identifier: .gregorian) // user calendar
        userCalendar.timeZone = timeZone
        let year = userCalendar.component(.year, from: self)
        
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = 1
        dateComponents.day = 1
        
        // Create date from components
        let someDateTime = userCalendar.date(from: dateComponents)
        return someDateTime
    }
    
    public func startNextYear(timeZone: TimeZone) -> Date? {
        return self.startOfYear(timeZone: timeZone)?.adjust(.year, offset: 1)
    }
    
    public func previusYearStart(timeZone: TimeZone) -> Date? {
        return self.startOfYear(timeZone: timeZone)?.adjust(.year, offset: -1)
    }
    
    public func dayBefore(timeZone: TimeZone) -> Date {
        return self.adjust(.day, offset: -1, timeZone: timeZone)
    }
    public func dayAfter(timeZone: TimeZone) -> Date {
        return self.adjust(.day, offset: 1, timeZone: timeZone)
    }
    
    static func from(year: Int, month: Int, day: Int, timeZone: TimeZone) -> Date {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = timeZone
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        let date = gregorianCalendar.date(from: dateComponents)!
        return date
    }
    
    public func allDates(till endDate: Date) -> [Date] {
        var date = self
        var array: [Date] = []
        while date <= endDate {
            array.append(date)
            date = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: date)!
        }
        return array
    }
    
    /// Returns the amount of years from another date
    public func years(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    public func months(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    public func weeks(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    public func days(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    public func hours(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    public func minutes(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    public func seconds(from date: Date) -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    public func offset(from date: Date) -> Int {
        //        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        //        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        //        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        //        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        //        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        //        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        //        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        //        return ""
        return self.months(from: date)
    }
}
