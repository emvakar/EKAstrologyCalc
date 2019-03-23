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

    /// восход луны
    public var moonRise: Date?

    /// заход луны
    public var moonSet: Date?

    public init(age: Int, zodiacSign: MoonZodiacSign, moonRise: Date?, moonSet: Date?) {
        self.age = age
        self.zodiacSign = zodiacSign
        self.moonRise = moonRise
        self.moonSet = moonSet
    }
}
