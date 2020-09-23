//
//  MoonTrajectoryCalculator.swift
//  EKAstrologyCalc
//
//  Created by Vasile Morari on 23.09.2020.
//

import Foundation

public protocol MoonTrajectoryCalculatorProtocol {
    func getMoonTrajectory(date: Date) -> EKMoonTrajectory
}

public final class MoonTrajectoryCalculator: MoonTrajectoryCalculatorProtocol {
    
    private let moonAgeCalculator: MoonAgeCalculatorProtocol
    
    public init(moonAgeCalculator: MoonAgeCalculatorProtocol) {
        self.moonAgeCalculator = moonAgeCalculator
    }
    
    ///Получить знак зодиака для дуны, траекторию луны, фазу луны
    public func getMoonTrajectory(date: Date) -> EKMoonTrajectory {
        let age: Double = moonAgeCalculator.getMoonAge(date: date)
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
}
