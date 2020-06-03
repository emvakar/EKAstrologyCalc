//
//  EKAstrologyModel.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit
import CoreLocation

/// Модель со всей инфой
///
/// - date: Date - дата обычная, например 01.01.1970
/// - location: CLLocation - гео позиция
/// - trajectory: EKMoonTrajectory - траектория луны
/// - phase: EKMoonPhase - фаза луны
/// - moonModels: [MoonModel] - модель лунных дней для даты
public class EKAstrologyModel {

    /// дата обычная, например 01.01.1970
    public var date: Date = Date()

    /// гео позиция
    public var location: CLLocation

    /// траектория луны
    public var trajectory: EKMoonTrajectory

    /// фаза луны
    public var phase: EKMoonPhase

    /// модель лунных дней для даты
    public var moonModels: [EKMoonModel]
    
    public let nextLunarEclipse: EKEclipse
    
    public let previousLunarEclipse: EKEclipse

    init(date: Date, location: CLLocation, trajectory: EKMoonTrajectory, phase: EKMoonPhase, moonModels: [EKMoonModel], lunarEclipses: [EKEclipse]) {
        self.date = date
        self.location = location
        self.trajectory = trajectory
        self.phase = phase
        self.moonModels = moonModels
        self.previousLunarEclipse = lunarEclipses[0]
        self.nextLunarEclipse = lunarEclipses[1]
    }
}
