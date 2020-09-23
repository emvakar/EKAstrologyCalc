//
//  EKMoonAgeCalculator.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 23.09.2020.
//  Copyright © 2020 Emil Karimov. All rights reserved.
//

import Foundation

public protocol EKMoonAgeCalculatorProtocol {
    
    func getMoonAge(date: Date) -> Double
    func getMoonAges(date: Date) -> [Int]
    
}

public final class EKMoonAgeCalculator {
    
    public init() { }
    
}

// MARK: - EKMoonAgeCalculatorProtocol

extension EKMoonAgeCalculator: EKMoonAgeCalculatorProtocol {
    
    ///Получить массив лунных дней в текущем Человеческом дне
    public func getMoonAges(date: Date) -> [Int] {
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
    
    ///Получить лунный день
    public func getMoonAge(date: Date) -> Double {
        
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
        
        ip = ((jd - 2451550.1) / 29.530588853).normalized
        age = ip * 29.53
        
        return age
    }
    
}

// MARK: - Private

extension EKMoonAgeCalculator {
    
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
    
}
