//
//  MoonPhaseCalculator.swift
//  EKAstrologyCalc
//
//  Created by Vasile Morari on 23.09.2020.
//

import Foundation

public protocol MoonPhaseCalculatorProtocol {
    func getMoonPhase(date: Date) -> EKMoonPhase
}

public final class MoonPhaseCalculator: MoonPhaseCalculatorProtocol {
    
    private let moonAgeCalculator: MoonAgeCalculatorProtocol
    
    public init(moonAgeCalculator: MoonAgeCalculatorProtocol) {
        self.moonAgeCalculator = moonAgeCalculator
    }
    
    ///Получить фазу луны
    public func getMoonPhase(date: Date) -> EKMoonPhase {
        let age: Double = moonAgeCalculator.getMoonAge(date: date)
        
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
}
