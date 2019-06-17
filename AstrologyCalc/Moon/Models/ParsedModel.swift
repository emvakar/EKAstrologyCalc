//
//  ParsedModel.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 17/06/2019.
//

import Foundation

public extension Date {
    
    static func dateFromString(string: String) -> Date? {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        return dateFormatter.date(from: string)
    }
}


public struct ZodiacParse: Codable {
    var newZodiac: NewZodiac?
    var newPhase: NewPhase?
    var oldZodiac: String?
    var oldPhase: String?
    let date: String
    var daysCount: Int = 29
    
    public func copy() -> ZodiacParse {
        let zodiac = ZodiacParse(newZodiac: self.newZodiac, newPhase: self.newPhase, oldZodiac: self.oldZodiac, oldPhase: self.oldPhase, date: self.date, daysCount: self.daysCount)
        return zodiac
    }
    
    public func toDic() -> [String: Any?] {
        var dic: [String: Any?] = [:]
        
        dic.updateValue(newZodiac?.toDic(), forKey: Keys.newZodiac.rawValue)
        dic.updateValue(newPhase?.toDic(), forKey: Keys.newPhase.rawValue)
        dic.updateValue(oldZodiac, forKey: Keys.oldZodiac.rawValue)
        dic.updateValue(oldPhase, forKey: Keys.oldPhase.rawValue)
        dic.updateValue(date, forKey: Keys.date.rawValue)
        dic.updateValue(daysCount, forKey: Keys.daysCount.rawValue)
        return dic
    }
}

public struct NewZodiac: Codable {
    let zodiac: String
    let date: String
    
    public func toDic() -> [String: Any?] {
        var dic: [String: Any?] = [:]
        
        dic.updateValue(zodiac, forKey: "zodiac")
        dic.updateValue(date, forKey: "date")
        
        return dic
    }
}

public struct NewPhase: Codable {
    let newPhase: String
    let date: String
    
    public func toDic() -> [String: Any?] {
        var dic: [String: Any?] = [:]
        
        dic.updateValue(newPhase, forKey: "newPhase")
        dic.updateValue(date, forKey: "date")
        
        return dic
    }
}

public enum Keys: String {
    
    case newPhase
    case oldPhase
    
    case oldZodiac
    case newZodiac
    
    case date
    case zodiac
    
    case daysCount
}
