//
//  EKAstrologyCalc.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 03/06/202020.
//  Copyright © 2020 Emil Karimov. All rights reserved.
//

import CoreLocation
import ESDateHelper

/// Calculator
public class EKAstrologyCalc {

    /// Location
    private var location: CLLocation

    // MARK: - Init
    
    public init(location: CLLocation) {
        self.location = location
    }

    /// get information by date
    /// - Parameter date: current date
    /// - Returns: Astrology model
    public func getInfo(date: Date) -> EKAstrologyModel {
        let phase = getMoonPhase(date: date)

        let trajectory = getMoonTrajectory(date: date)
        let moonModels = getMoonModels(date: date)
        let eclipses = [
            EKEclipseCalculator.getEclipseFor(date: date, eclipseType: .Lunar, next: false),
            EKEclipseCalculator.getEclipseFor(date: date, eclipseType: .Lunar, next: true)
        ]
        let (y, month, d, h, m, s, lat, lon) = getCurrentDate(date: date)
        let illumination = try? EKSunMoonCalculator(year: y, month: month, day: d, h: h, m: m, s: s, obsLon: lon, obsLat: lat).getMoonIllumination(date: date)
        let astrologyModel = EKAstrologyModel(
            date: date,
            location: location,
            trajectory: trajectory,
            phase: phase,
            moonModels: moonModels,
            lunarEclipses: eclipses,
            illumination: illumination
        )
        return astrologyModel
    }
}

// MARK: - Private

extension EKAstrologyCalc {

    // Получить модели лунного дня для текущего человеческого дня
    private func getMoonModels(date: Date) -> [EKMoonModel] {
        let startDate = date.startOfDay
        guard let endDate = date.endOfDay else { return [] }

        let ages = getMoonAges(date: date)
        let moonRise = getMoonRise(date: startDate).date
        let moonSet = getMoonSet(date: endDate).date
        let zodiacSignStart = getMoonZodicaSign(date: startDate)
        let zodiacSignEnd = getMoonZodicaSign(date: endDate)

        let prevStartDay = startDate.adjust(.day, offset: -1).startOfDay
        let nextEndDate = endDate.adjust(.day, offset: 1).endOfDay!

        let prevMoonRise = getMoonRise(date: prevStartDay).date
        var nextMoonRise = getMoonRise(date: nextEndDate).date

        if ages.count < 1 {
            return []
        } else if ages.count == 1 {
            let model = EKMoonModel(age: ages[0], sign: zodiacSignEnd, begin: prevMoonRise, finish: nextMoonRise)
            return [model]
        } else if ages.count == 2 {

            if (moonSet?.timeIntervalSince1970 ?? 0) < (nextMoonRise?.timeIntervalSince1970 ?? 0) && (moonSet?.timeIntervalSince1970 ?? 0) > (moonRise?.timeIntervalSince1970 ?? 0) {
                nextMoonRise = getMoonRise(date: endDate).date
            }

            let model1 = EKMoonModel(age: ages[0], sign: zodiacSignStart, begin: prevMoonRise, finish: moonRise)
            let model2 = EKMoonModel(age: ages[1], sign: zodiacSignEnd, begin: moonRise, finish: nextMoonRise)
            return [model1, model2]
        } else if ages.count == 3 {
            if (moonSet?.timeIntervalSince1970 ?? 0) < (nextMoonRise?.timeIntervalSince1970 ?? 0) && (moonSet?.timeIntervalSince1970 ?? 0) > (moonRise?.timeIntervalSince1970 ?? 0) {
                nextMoonRise = getMoonRise(date: endDate).date
            }

            let middleZodiacSign = (zodiacSignStart == zodiacSignEnd) ? zodiacSignStart : zodiacSignEnd
            let model1 = EKMoonModel(age: ages[0], sign: zodiacSignStart, begin: prevMoonRise, finish: moonRise)
            let model2 = EKMoonModel(age: ages[1], sign: middleZodiacSign, begin: moonRise, finish: moonSet)
            let model3 = EKMoonModel(age: ages[2], sign: zodiacSignEnd, begin: moonSet, finish: nextMoonRise)
            return [model1, model2, model3]
        } else {
            return []
        }
    }

    //Получить восход луны
    private func getMoonRise(date: Date) -> (date: Date?, error: Error?) {
        return getMoonRiseOrSet(date: date, isRise: true)
    }

    //Получить заход луны
    private func getMoonSet(date: Date) -> (date: Date?, error: Error?) {
        return getMoonRiseOrSet(date: date, isRise: false)
    }

    //Получить массив лунных дней в текущем Человеческом дне
    private func getMoonAges(date: Date) -> [Int] {
        let startDate = date.startOfDay
        let endDate = startDate.adjust(.day, offset: 1).adjust(.second, offset: -1)

        var ageStart = getMoonAge(date: startDate)
        var ageEnd = getMoonAge(date: endDate)

        let nextStartInt = Int(ageStart) + 1
        if (Double(nextStartInt) - ageStart) < 0.2 {
            ageStart = Double(nextStartInt)
        }

        let nextEndInt = Int(ageEnd) + 1
        if (Double(nextEndInt) - ageEnd) < 0.2 {
            ageEnd = Double(nextEndInt)
        }

        let ageStartInt = Int(ageStart)
        let ageEndInt = Int(ageEnd)

        if ageStartInt == ageEndInt {
            return [ageStartInt]
        } else {
            return getInt(from: ageStartInt, to: ageEndInt, module: 30)
        }
    }

    //Получить восход/заход луны для лунного дня
    private func getMoonRiseOrSet(date: Date, isRise: Bool) -> (date: Date?, error: Error?) {
        let (y, month, d, h, m, s, lat, lon) = getCurrentDate(date: date)

        do {
            let moonCalculator = try EKSunMoonCalculator(year: y, month: month, day: d, h: h, m: m, s: s, obsLon: lon, obsLat: lat)
            moonCalculator.calcSunAndMoon()
            var moonDateInt: [Int]
            if isRise {
                moonDateInt = try EKSunMoonCalculator.getDate(moonCalculator.moonRise)
            } else {
                moonDateInt = try EKSunMoonCalculator.getDate(moonCalculator.moonSet)
            }

            let moonDate = getDateFromComponents(moonDateInt)
            return (moonDate, nil)
        } catch let error {
            return (nil, error)
        }
    }

    //Получить знак зодиака для луны
    public func getMoonZodicaSign(date: Date) -> EKMoonZodiacSign {
        var longitude: Double = 0.0
        var zodiac: EKMoonZodiacSign

        var yy: Double = 0.0
        var mm: Double = 0.0
        var k1: Double = 0.0
        var k2: Double = 0.0
        var k3: Double = 0.0
        var jd: Double = 0.0
        var ip: Double = 0.0
        var dp: Double = 0.0
        var rp: Double = 0.0

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

        ip = ip * 2 * .pi

        dp = 2 * .pi * normalize((jd - 2451562.2) / 27.55454988)

        rp = normalize((jd - 2451555.8) / 27.321582241)
        longitude = 360 * rp + 6.3 * sin(dp) + 1.3 * sin(2 * ip - dp) + 0.7 * sin(2 * ip)

        if (longitude < 33.18) {
            zodiac = .aries
        } else if (longitude < 51.16) {
            zodiac = .taurus
        } else if (longitude < 93.44) {
            zodiac = .gemini
        } else if (longitude < 119.48) {
            zodiac = .cancer
        } else if (longitude < 135.30) {
            zodiac = .leo
        } else if (longitude < 173.34) {
            zodiac = .virgo
        } else if (longitude < 224.17) {
            zodiac = .libra
        } else if (longitude < 242.57) {
            zodiac = .scorpio
        } else if (longitude < 271.26) {
            zodiac = .sagittarius
        } else if (longitude < 302.49) {
            zodiac = .capricorn
        } else if (longitude < 311.72) {
            zodiac = .aquarius
        } else if (longitude < 348.58) {
            zodiac = .pisces
        } else {
            zodiac = .aries
        }

        return zodiac
    }

    //Получить фазу луны
    private func getMoonPhase(date: Date) -> EKMoonPhase {
        let age: Double = getMoonAge(date: date)

        var phase: EKMoonPhase

        if (age < 1.84566) {
            phase = .newMoon
        } else if (age < 5.53699) {
            phase = .waxingCrescent
        } else if (age < 9.22831) {
            phase = .firstQuarter
        } else if (age < 12.91963) {
            phase = .waxingGibbous
        } else if (age < 16.61096) {
            phase = .fullMoon
        } else if (age < 20.30228) {
            phase = .waningGibbous
        } else if (age < 23.99361) {
            phase = .lastQuarter
        } else if (age < 27.68493) {
            phase = .waningCrescent
        } else {
            phase = .newMoon
        }

        return phase
    }

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
    private func getMoonTrajectory(date: Date) -> EKMoonTrajectory {
        let age: Double = getMoonAge(date: date)
        var trajectory: EKMoonTrajectory


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
    public func getCurrentDate(date: Date) -> (y: Int, month: Int, d: Int, h: Int, m: Int, s: Int, lat: Double, lon: Double) {
        let (y, month, d, h, m, s) = getDateComponents(from: date)
        let lat = location.coordinate.latitude * EKSunMoonCalculator.DEG_TO_RAD
        let lon = location.coordinate.longitude * EKSunMoonCalculator.DEG_TO_RAD
        return (y, month, d, h, m, s, lat, lon)
    }

    /*
     Получить массив чисел между числами N и M (кроме 0),
     если M меньше N, то к M прибавляется модуль -- например,
     получить числа между 28 и 2 по модулю 30, будет 28, 29, 1, 2
     */
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
        let endDate = Calendar.current.date(byAdding: components, to: startOfDate(date))
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
