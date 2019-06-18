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
    
    func stringFromDate() -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        
        return dateFormatter.string(from: self)
    }
}


public struct ZodiacParse: Codable {
    var newZodiac: NewZodiac?
    var newPhase: NewPhase?
    var oldZodiac: String?
    var oldPhase: String?
    var date: Date = Date()
    var daysCount: Int = 29
    
    enum CodingKeys: String, CodingKey {
        
        case oldPhase = "oldPhase"
        case date = "date"
        case daysCount = "daysCount"
        case newPhase = "newPhase"
        case oldZodiac = "oldZodiac"
        case newZodiac = "newZodiac"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        oldPhase = try values.decodeIfPresent(String.self, forKey: .oldPhase)
        let stringDate = try values.decode(String.self, forKey: .date)
        if let modelDate = Date(fromString: stringDate, format: .custom("yyyy-MM-dd'T'HH:mmZ"))?.startOfDay {
            self.date = modelDate
        }
        daysCount = try values.decode(Int.self, forKey: .daysCount)
        newPhase = try values.decodeIfPresent(NewPhase.self, forKey: .newPhase)
        oldZodiac = try values.decodeIfPresent(String.self, forKey: .oldZodiac)
        newZodiac = try values.decodeIfPresent(NewZodiac.self, forKey: .newZodiac)
    }
    
    init(newZodiac: NewZodiac?, newPhase: NewPhase?, oldZodiac: String?, oldPhase: String?, date: Date, daysCount: Int) {
        self.newZodiac = newZodiac
        self.newPhase = newPhase
        self.oldZodiac = oldZodiac
        self.oldPhase = oldPhase
        self.date = date
        self.daysCount = daysCount
        
    }
    
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
