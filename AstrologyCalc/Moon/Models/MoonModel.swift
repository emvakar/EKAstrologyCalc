//
//  MoonModel.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit

/// Модель лунного дня
///
/// - age: Int - лунный день
/// - zodiacSign: MoonZodiacSign - лунный знак зодиака
/// - moonRise: Date? - восход луны
/// - moonSet: Date? - заход луны
public class MoonModel {

    /// лунный день
    public var age: Int

    /// лунный знак зодиака
    public var zodiacSign: MoonZodiacSign
    
    ///начало знака зодиака
    public var zodiacSignDate: Date?

    /// восход луны (начало лунного дня)
    public var moonRise: Date?

    /// заход луны (конец лунного дня)
    public var moonSet: Date?

    public init(age: Int, zodiacSign: MoonZodiacSign, zodiacSignDate: Date?, moonRise: Date?, moonSet: Date?) {
        self.age = age
        self.zodiacSign = zodiacSign
        self.zodiacSignDate = zodiacSignDate
        self.moonRise = moonRise
        self.moonSet = moonSet
    }
}
