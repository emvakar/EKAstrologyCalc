//
//  EKMoonTrajectoryCalculator.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 23.09.2020.
//  Copyright © 2020 Emil Karimov. All rights reserved.
//

import Foundation

public protocol EKMoonTrajectoryCalculatorProtocol {
    
    func getMoonTrajectory(date: Date) -> EKMoonTrajectory
    
}

public final class EKMoonTrajectoryCalculator {
    
    private let moonAgeCalculator: EKMoonAgeCalculatorProtocol
    
    public init(moonAgeCalculator: EKMoonAgeCalculatorProtocol) {
        self.moonAgeCalculator = moonAgeCalculator
    }
    
}

// MARK: - EKMoonTrajectoryCalculatorProtocol

extension EKMoonTrajectoryCalculator: EKMoonTrajectoryCalculatorProtocol {
    
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
