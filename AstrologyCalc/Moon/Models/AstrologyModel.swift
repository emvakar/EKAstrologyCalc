//
//  AstrologyModel.swift
//  AstrologyCalc
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
/// - trajectory: MoonTrajectory - траектория луны
/// - phase: MoonPhase - фаза луны
/// - moonModels: [MoonModel] - модель лунных дней для даты
public class AstrologyModel {

    /// дата обычная, например 01.01.1970
    public var date: Date = Date()

    /// гео позиция
    public var location: CLLocation

    /// траектория луны
    public var trajectory: MoonTrajectory

    /// фаза луны
    public var phase: MoonPhase

    /// модель лунных дней для даты
    public var moonModels: [MoonModel]
    
    public let nextLunarEclipse: Eclipse
    
    public let previousLunarEclipse: Eclipse

    init(date: Date, location: CLLocation, trajectory: MoonTrajectory, phase: MoonPhase, moonModels: [MoonModel], lunarEclipses: [Eclipse]) {
        self.date = date
        self.location = location
        self.trajectory = trajectory
        self.phase = phase
        self.moonModels = moonModels
        self.previousLunarEclipse = lunarEclipses[0]
        self.nextLunarEclipse = lunarEclipses[1]
    }
}
