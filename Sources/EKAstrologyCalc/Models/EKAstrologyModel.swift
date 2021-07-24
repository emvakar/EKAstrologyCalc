//
//  EKAstrologyModel.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import CoreLocation

/// Model with all information
///
/// - date: Date, ect 01.01.1970
/// - location: CLLocation
/// - trajectory: EKMoonTrajectory
/// - phase: EKMoonPhase
/// - moonModels: [EKMoonModel]
/// - nextLunarEclipse
/// - previousLunarEclipse
/// - illumination: EKIllumination?
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
    
    public let illumination: EKIllumination?

    public let sunModel: EKSunMoonModel?
    public let moonModel: EKSunMoonModel?

    init(date: Date, location: CLLocation, trajectory: EKMoonTrajectory, phase: EKMoonPhase, moonModels: [EKMoonModel], lunarEclipses: [EKEclipse], illumination: EKIllumination?, sunModel: EKSunMoonModel?, moonModel: EKSunMoonModel?) {
        self.date = date
        self.location = location
        self.trajectory = trajectory
        self.phase = phase
        self.moonModels = moonModels
        self.previousLunarEclipse = lunarEclipses[0]
        self.nextLunarEclipse = lunarEclipses[1]
        self.illumination = illumination
        self.sunModel = sunModel
        self.moonModel = moonModel
    }
}
