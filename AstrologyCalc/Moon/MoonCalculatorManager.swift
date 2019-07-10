//
//  MoonCalculatorManager.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import DevHelper

//Тут все расчеты
public class MoonCalculatorManager {
    
    //Геопозиция
    private var location: CLLocation
    private var parsedModels: [ZodiacParse] = []
    
    //Вызвать этот коснтруктор
    public init(location: CLLocation) {
        self.location = location
        
        if let path = Bundle(for: MoonCalculatorManager.self).path(forResource: "parsing", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonDecoder = JSONDecoder()
                
                let models = try jsonDecoder.decode([ZodiacParse].self, from: data)
                self.parsedModels = models
                
            } catch {
                // handle error
            }
        }
        
    }
    
    //Получить необходимую инфу
    public func getInfo(date: Date, city: DBCityModel?, timeZone: TimeZone) -> AstrologyModel {
        var currentCity: DBCityModel
        if let nonOptional = city {
            currentCity = nonOptional
        } else {
            currentCity = DataBaseManager().makeCountriesFromJSON()[19].cities.first(where: { $0.cityName.lowercased().contains("лос-ан") }) ?? DataBaseManager().makeCountriesFromJSON()[0].cities[0]
        }
        
        let trajectory = self.getMoonTrajectory(date: date)
        
        let moonModels = self.getMoonModels(date: date, city: currentCity, timeZone: timeZone)
        
        let phase = self.getMoonPhase(date: date, city: currentCity, timeZone: timeZone)
        
        let eclipses = [
            EclipseCalculator.getEclipseFor(date: date, eclipseType: .Lunar, next: false),
            EclipseCalculator.getEclipseFor(date: date, eclipseType: .Lunar, next: true)
        ]
        
        let astrologyModel = AstrologyModel(
            date: date,
            location: self.location,
            trajectory: trajectory,
            phase: phase,
            moonModels: moonModels,
            lunarEclipses: eclipses
        )
        return astrologyModel
    }
}

extension MoonCalculatorManager {
    
    public func getMoonDays(at date: Date) -> Int {
        
        var myDate = date
        var age: Double = self.getMoonAge(date: myDate.startOfMonth())
        
        var daysCount = 0
        
        while age >= 1.84566 {
            daysCount += 1
            myDate = myDate.adjust(.day, offset: 1)
            age = self.getMoonAge(date: myDate.startOfMonth())
        }
        
        return daysCount
    }
    
    //Получить модели лунного дня для текущего человеческого дня
//    private func getMoonModels(date: Date) -> [MoonModel] {
//        var dateMoonModels = self.getMoonModelsOnlyFor(date: date)
//        let yesterdayModels = self.getMoonModelsOnlyFor(date: date.adjust(.day, offset: -1))
//
//        // ищем заходы, в предыдущем дне, которые указывали на текущий
//        // и добавляем их в текущий
//        yesterdayModels.forEach { (model) in
//            guard let moonSet = model.moonSet, Calendar.current.isDate(moonSet, inSameDayAs: date) else {
//                return
//            }
//
//            dateMoonModels.first?.moonRise = moonSet
//        }
//
//        dateMoonModels.removeAll {
//            // ищем заходы в текущем дне, которые на деле относятся к предыдущим
//            if let moonSet = $0.moonSet, !Calendar.current.isDate(moonSet, inSameDayAs: date) {
//                $0.moonSet = nil
//            }
//
//            // ищем восходы, которые не принадлежат текущему дню и удаляем их
//            if let moonRise = $0.moonRise, !Calendar.current.isDate(moonRise, inSameDayAs: date) {
//                return true
//            }
//
//            return false
//        }
//
//        return dateMoonModels
//    }
    
    public func getMoonModels(date: Date, city: DBCityModel, timeZone: TimeZone) -> [MoonModel] {
        
        let startOfDay = date.startOfDay
        guard let endOfDay = date.endOfDay else { return [] }
        let dayInterval = DateInterval(start: startOfDay, end: endOfDay)
        
        let allMoonDays = city.moonDays
        var filteredMoonDays = [MoonModel]()
        
        var correctMoonDay: (index: Int, moonDay: DBMoonDayModel)?
        var moonDayForExtraCase: (index: Int, moonDay: DBMoonDayModel)? // лунный день для последнего случая (когда 1 лунный день)
        
        //возможен случай с 3мя лунными днями в один календарный день (тогда в цикле 2 раза найдется подходящее условие), но для последующей логики мы берем именно первый попавшийся лунный день
        for (index, model) in allMoonDays.enumerated() {
            
            guard let modelDate = model.moonStartDate else { break }
            if dayInterval.contains(modelDate) {
                correctMoonDay = (index, model)
                break
            }
            
            //для случая с 1 лунным днем, чтобы второй раз не ходить по циклу
            if modelDate < startOfDay {
                moonDayForExtraCase = (index, model)
            }
            
            //если лунный день начинается после конца календарного дня, то обрываем цикл
            if modelDate > endOfDay {
                break
            }
        }

        //если лунный день попал в переданный календарный день, то есть 2 варианта: либо в этот календарный день 2 лунных дня (если конец лунного дня приходится на следующий календарный день), либо 3 (если конец лунного дня приходится на текущий день)
        if let correctMoonDay = correctMoonDay {
            
            let currentMoonDay = correctMoonDay.moonDay
            
            let nextIndex = ((correctMoonDay.index + 1) < allMoonDays.count) ? (correctMoonDay.index + 1) : (allMoonDays.count - 1)
            let nextMoonDay = allMoonDays[nextIndex]
            let prevIndex = ((correctMoonDay.index - 1) >= 0) ? (correctMoonDay.index - 1) : 0
            let previousMoonDay = allMoonDays[prevIndex]
            
            let firstMoonDay = self.makeMoonModel(age: currentMoonDay.age, zodiacSign: currentMoonDay.sign, zodiacSignDate: currentMoonDay.signDate.toDate, moonRise: currentMoonDay.moonStartDate, moonSet: nextMoonDay.moonStartDate)
            
            let secondMoonDay = self.makeMoonModel(age: previousMoonDay.age, zodiacSign: previousMoonDay.sign, zodiacSignDate: previousMoonDay.signDate.toDate, moonRise: previousMoonDay.moonStartDate, moonSet: currentMoonDay.moonStartDate)
            
            filteredMoonDays = [secondMoonDay, firstMoonDay]
            
            //случай с 3 днями
            if ((correctMoonDay.index + 2) < allMoonDays.count), let nextMoonDayStart = allMoonDays[correctMoonDay.index + 1].moonStartDate, dayInterval.contains(nextMoonDayStart) {
                let thirdMoonDay = self.makeMoonModel(age: nextMoonDay.age, zodiacSign: nextMoonDay.sign, zodiacSignDate: nextMoonDay.signDate.toDate, moonRise: nextMoonDay.moonStartDate, moonSet: allMoonDays[correctMoonDay.index + 2].moonStartDate)
                
                filteredMoonDays.append(thirdMoonDay)
            }
            
            var models = [MoonModel]()
            for f in filteredMoonDays {
                if models.contains(where: { $0.age == f.age }) {
                    continue
                }
                models.append(f)
            }
            
            return models
        }
        
        //если лунный день не попал в переданный календарный день, то тут 1 вариант: в этот календарный день содержит 1 лунный день (он начался раньше календарного дня и закончится позже календарного дня)
        if let moonDayTuple = moonDayForExtraCase, ((moonDayTuple.index + 1) < allMoonDays.count) {
            let moonDay = self.makeMoonModel(age: moonDayTuple.moonDay.age, zodiacSign: moonDayTuple.moonDay.sign, zodiacSignDate: moonDayTuple.moonDay.signDate.toDate, moonRise: moonDayTuple.moonDay.moonStartDate, moonSet: allMoonDays[moonDayTuple.index + 1].moonStartDate)
            filteredMoonDays = [moonDay]
            return filteredMoonDays
        }
        
        var models = [MoonModel]()
        for f in filteredMoonDays {
            if models.contains(where: { $0.age == f.age }) {
                continue
            }
            models.append(f)
        }
        
        return models
    }
    
    private func makeMoonModel(age: Int, zodiacSign: String, zodiacSignDate: Date?, moonRise: Date?, moonSet: Date?) -> MoonModel {
        let zodSign = MoonZodiacSign(rawValue: zodiacSign) ?? .aquarius
        return MoonModel(age: age, zodiacSign: zodSign, zodiacSignDate: zodiacSignDate, moonRise: moonRise, moonSet: moonSet)
    }
    
//    private func getMoonModelsOnlyFor(date: Date) -> [MoonModel] {
//        let startDate = date.startOfDay
//        let endDate = date.adjust(.day, offset: 1)
//        //guard let endDate = date.endOfDay else { return [] }
//
//        let ages = self.getMoonAges(date: date)
//        let moonRise = self.getMoonRise(date: startDate).date
//        let moonSet = self.getMoonSet(date: endDate).date
//        let zodiacSignStart = self.getMoonZodicaSign(date: startDate)
//        let zodiacSignEnd = self.getMoonZodicaSign(date: endDate)
//
//        if ages.count < 1 {
//            return []
//        } else if ages.count == 1 {
//            let model = MoonModel(age: ages[0], zodiacSign: zodiacSignEnd, moonRise: nil, moonSet: nil)
//            return [model]
//        } else if ages.count == 2 {
//            let model1 = MoonModel(age: ages[0], zodiacSign: zodiacSignStart, moonRise: nil, moonSet: moonRise)
//            let model2 = MoonModel(age: ages[1], zodiacSign: zodiacSignEnd, moonRise: moonRise, moonSet: nil)
//            return [model1, model2]
//        } else if ages.count == 3 {
//            let middleZodiacSign = (zodiacSignStart == zodiacSignEnd) ? zodiacSignStart : zodiacSignEnd
//            let model1 = MoonModel(age: ages[0], zodiacSign: zodiacSignStart, moonRise: nil, moonSet: moonRise)
//            let model2 = MoonModel(age: ages[1], zodiacSign: middleZodiacSign, moonRise: moonRise, moonSet: moonSet)
//            let model3 = MoonModel(age: ages[2], zodiacSign: zodiacSignEnd, moonRise: moonSet, moonSet: nil)
//            return [model1, model2, model3]
//        } else {
//            return []
//        }
//    }
    
    //Получить восход луны
//    private func getMoonRise(date: Date) -> (date: Date?, error: Error?) {
//        return self.getMoonRiseOrSet(date: date, isRise: true)
//    }
    
    //Получить заход луны
//    private func getMoonSet(date: Date) -> (date: Date?, error: Error?) {
//        return self.getMoonRiseOrSet(date: date, isRise: false)
//    }
    
    //Получить массив лунных дней в текущем Человеческом дне
//    private func getMoonAges(date: Date) -> [Int] {
//        let startDate = date.startOfDay
//        let endDate = startDate.adjust(.day, offset: 1)//.adjust(.second, offset: -1)
//
//        var ageStart = self.getMoonAge(date: startDate)
//        var ageEnd = self.getMoonAge(date: endDate)
//
//        let nextStartInt = Int(ageStart) + 1
//        if (Double(nextStartInt) - ageStart) < 0.2 {
//            ageStart = Double(nextStartInt)
//        }
//
//        let nextEndInt = Int(ageEnd) + 1
//        if (Double(nextEndInt) - ageEnd) < 0.2 {
//            ageEnd = Double(nextEndInt)
//        }
//
//        let ageStartInt = Int(ageStart)
//        let ageEndInt = Int(ageEnd)
//
//        if ageStartInt == ageEndInt {
//            return [ageStartInt]
//        } else {
//
//            let module = self.getModule(for: date)
//
//            return self.getInt(from: ageStartInt, to: ageEndInt, module: module)
//        }
//    }
    
    /// получение модуля для количества дней в лунном месяце
//    private func getModule(for date: Date) -> Int {
//        var module = 0
//
//        var lastCountDays = 0
//
//        var dateForModule = date.startOfDay
//        while lastCountDays <= 30 {
//
//            let nextDate = dateForModule.adjust(.day, offset: 1)
//            let daysInMonth = self.getDaysInMoonMonth(date: nextDate)
//            if lastCountDays < 30 && daysInMonth > 29 {
//
//                module = daysInMonth
//                break
//            }
//            dateForModule = nextDate
//            lastCountDays = daysInMonth
//
//        }
//
//        return module
//    }
    
    /// получение лня в на конкретную дату
//    private func getDaysInMoonMonth(date: Date) -> Int {
//        let startDate = date.startOfDay
//        let module = self.parsedModels.first(where: {  $0.date.isSameDate(startDate) })?.daysCount ?? 29
//        return module
//    }
//
    //Получить восход/заход луны для лунного дня
//    private func getMoonRiseOrSet(date: Date, isRise: Bool) -> (date: Date?, error: Error?) {
//        let (y, month, d, h, m, s, lat, lon) = self.getCurrentData(date: date)
//
//        do {
//            let moonCalculator = try SunMoonCalculator(year: y, month: month, day: d, h: h, m: m, s: s, obsLon: lon, obsLat: lat)
//            moonCalculator.calcSunAndMoon()
//            var moonDateInt: [Int]
//            if isRise {
//                moonDateInt = try SunMoonCalculator.getDate(moonCalculator.moonRise)
//            } else {
//                moonDateInt = try SunMoonCalculator.getDate(moonCalculator.moonSet)
//            }
//
//            let moonDate = self.getDateFromComponents(moonDateInt)
//            return (moonDate, nil)
//        } catch let error {
//            return (nil, error)
//        }
//    }
    
    //Получить знак зодиака для луны
//    public func getMoonZodicaSign(date: Date) -> MoonZodiacSign {
//        var longitude: Double = 0.0
//        var zodiac: MoonZodiacSign
//
//        var yy: Double = 0.0
//        var mm: Double = 0.0
//        var k1: Double = 0.0
//        var k2: Double = 0.0
//        var k3: Double = 0.0
//        var jd: Double = 0.0
//        var ip: Double = 0.0
//        var dp: Double = 0.0
//        var rp: Double = 0.0
//
//        let year: Double = Double(Calendar.current.component(.year, from: date))
//        let month: Double = Double(Calendar.current.component(.month, from: date))
//        let day: Double = Double(Calendar.current.component(.day, from: date))
//
//        yy = year - floor((12 - month) / 10)
//        mm = month + 9.0
//        if (mm >= 12) {
//            mm = mm - 12
//        }
//
//        k1 = floor(365.25 * (yy + 4712))
//        k2 = floor(30.6 * mm + 0.5)
//        k3 = floor(floor((yy / 100) + 49) * 0.75) - 38
//
//        jd = k1 + k2 + day + 59
//        if (jd > 2299160) {
//            jd = jd - k3
//        }
//
//        ip = normalize((jd - 2451550.1) / 29.530588853)
//
//        ip = ip * 2 * .pi
//
//        dp = 2 * .pi * normalize((jd - 2451562.2) / 27.55454988)
//
//        rp = normalize((jd - 2451555.8) / 27.321582241)
//        longitude = 360 * rp + 6.3 * sin(dp) + 1.3 * sin(2 * ip - dp) + 0.7 * sin(2 * ip)
//
//        if (longitude < 33.18) {
//            zodiac = .aries
//        } else if (longitude < 51.16) {
//            zodiac = .cancer
//        } else if (longitude < 93.44) {
//            zodiac = .gemini
//        } else if (longitude < 119.48) {
//            zodiac = .cancer
//        } else if (longitude < 135.30) {
//            zodiac = .leo
//        } else if (longitude < 173.34) {
//            zodiac = .virgo
//        } else if (longitude < 224.17) {
//            zodiac = .libra
//        } else if (longitude < 242.57) {
//            zodiac = .scorpio
//        } else if (longitude < 271.26) {
//            zodiac = .sagittarius
//        } else if (longitude < 302.49) {
//            zodiac = .capricorn
//        } else if (longitude < 311.72) {
//            zodiac = .aquarius
//        } else if (longitude < 348.58) {
//            zodiac = .pisces
//        } else {
//            zodiac = .aries
//        }
//
//        return zodiac
//    }
    
    
    
    //Получить фазу луны
    private func getMoonPhase(date: Date, city: DBCityModel, timeZone: TimeZone) -> DBMoonPhase {
        
        let moonDays = city.moonDays
        
        let ms = moonDays.filter({ $0.moonStartDate?.isSameDate(date, timeZone: timeZone) ?? false })
        
        var phase = ms.first?.moonPhase ?? .newMoon
        if let p = ms.first?.moonPhase {
            phase = p
        } else {
            phase = moonDays.filter({ $0.moonStartDate?.isSameDate(date.adjust(.day, offset: -1)) ?? false }).last?.moonPhase ?? .newMoon
        }
        
        if ms.contains(where: { ($0.age == 1 && $0.moonPhase == .fullMoon) }) {
            return .newMoon
        }
        
        for m in ms {
            if m.moonPhase == DBMoonPhase.newMoon || m.moonPhase == DBMoonPhase.fullMoon {
                if (m.age == 1) && m.moonPhase == DBMoonPhase.fullMoon {
                    return .newMoon
                } else if (m.age > 27) && m.moonPhase == DBMoonPhase.fullMoon {
                    return .phase4
                }
                return m.moonPhase!
            }
        }
        
        return phase
    }
    
    
//    private func getMoonPhase(date: Date) -> MoonPhase {
//        let age: Double = self.getMoonAge(date: date)
//
//        var phase: MoonPhase
//
//        if (age < 1.84566) {
//            phase = .newMoon
//        } else if (age < 5.53699) {
//            phase = .waxingCrescent
//        } else if (age < 9.22831) {
//            phase = .firstQuarter
//        } else if (age < 12.91963) {
//            phase = .waxingGibbous
//        } else if (age < 16.61096) {
//            phase = .fullMoon
//        } else if (age < 20.30228) {
//            phase = .waningGibbous
//        } else if (age < 23.99361) {
//            phase = .lastQuarter
//        } else if (age < 27.68493) {
//            phase = .waningCrescent
//        } else {
//            phase = .newMoon
//        }
//
//        return phase
//    }
    
    //Получить лунный день
    private func getMoonAge(date: Date) -> Double {
        
        var age: Double = 0.0
        
        var yy: Double = 0.0
        var mm: Double = 0.0
        var k1: Double = 0.0
        var k2: Double = 0.0
        var k3: Double = 0.0
        var jd: Double = 0.0
        var ip: Double = 0.0
        
        let year: Double = Double(Calendar.current.component(.year, from: date))
        let month: Double = Double(Calendar.current.component(.month, from: date))
        let day: Double = Double(Calendar.current.component(.day, from: date))
        
        yy = year - floor((12 - month) / 10)
        mm = month + 9.0
        if (mm >= 12) {
            mm = mm - 12
        }
        
        k1 = floor(365.25 * (yy + 4712))
        k2 = floor(30.6 * mm + 0.5)
        k3 = floor(floor((yy / 100) + 49) * 0.75) - 38
        
        jd = k1 + k2 + day + 59
        if (jd > 2299160) {
            jd = jd - k3
        }
        
        ip = normalize((jd - 2451550.1) / 29.530588853)
        age = ip * 29.53
        
        return age
    }
    
    //Получить знак зодиака для дуны, траекторию луны, фазу луны
    private func getMoonTrajectory(date: Date) -> MoonTrajectory {
        let age: Double = self.getMoonAge(date: date)
        var trajectory: MoonTrajectory
        
        
        if (age < 1.84566) {
            trajectory = .ascendent
        } else if (age < 5.53699) {
            trajectory = .ascendent
        } else if (age < 9.22831) {
            trajectory = .ascendent
        } else if (age < 12.91963) {
            trajectory = .ascendent
        } else if (age < 16.61096) {
            trajectory = .descendent
        } else if (age < 20.30228) {
            trajectory = .descendent
        } else if (age < 23.99361) {
            trajectory = .descendent
        } else if (age < 27.68493) {
            trajectory = .descendent
        } else {
            trajectory = .ascendent
        }
        
        return trajectory
    }
    
    //Получить дату из кмпонент дня -- например [1970, 1, 1, 12, 24, 33] -> 01.01.1970 12:24:33
    private func getDateFromComponents(_ components: [Int]) -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.year = components[0]
        dateComponents.month = components[1]
        dateComponents.day = components[2]
        dateComponents.hour = components[3]
        dateComponents.minute = components[4]
        dateComponents.second = components[5]
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let date = calendar.date(from: dateComponents)
        
        return date
    }
    
    //Получить дату дату и геопозицию ввиде -> [1970, 1, 1, 12, 24, 33, широта, долгота]
    public func getCurrentData(date: Date) -> (y: Int, month: Int, d: Int, h: Int, m: Int, s: Int, lat: Double, lon: Double) {
        let (y, month, d, h, m, s) = self.getDateComponents(from: date)
        let lat = self.location.coordinate.latitude * SunMoonCalculator.DEG_TO_RAD
        let lon = self.location.coordinate.longitude * SunMoonCalculator.DEG_TO_RAD
        return (y, month, d, h, m, s, lat, lon)
    }
    
    //Получить массив чисел между числами N и M (кроме 0), если M меньше N, то к M прибавляется модуль -- например, получить числа между 28 и 2 по модулю 30, будет 28, 29, 1, 2
    private func getInt(from: Int, to: Int, module: Int) -> [Int] {
        var toValue = to
        if toValue == 0 {
            toValue = module - 1
        }
        var fromValue = from
        if fromValue == 0 {
            fromValue = module - 1
        }
        
        if fromValue == toValue {
            return [from]
        } else {
            var array = [Int]()
            var next = fromValue
            array.append(next)
            
            while next != toValue {
                next += 1
                if next > module {
                    next = 1
                }
                array.append(next)
            }
            
            return array
        }
    }
    
    //Получить компоненты дня -- например 01.01.1970 12:24:33 -> [1970, 1, 1, 12, 24, 33]
    private func getDateComponents(from date: Date) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        return (year, month, day, hour, minute, second)
    }
    
    //Получить начало дня -- например 01.01.1970 23:59:59
    private func startOfDate(_ date: Date) -> Date {
        let startDate = Calendar.current.startOfDay(for: date)
        return startDate
    }
    
    //Получить конец дня -- например 01.01.1970 00:00:00
    private func endOfDate(_ date: Date) -> Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = Calendar.current.date(byAdding: components, to: self.startOfDate(date))
        return endDate
    }
    
    //нормализовать число, т.е. число от 0 до 1
    private func normalize(_ value: Double) -> Double {
        var v = value - floor(value)
        if (v < 0) {
            v = v + 1
        }
        return v
    }
}
