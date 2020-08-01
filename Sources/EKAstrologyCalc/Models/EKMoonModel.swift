//
//  EKMoonModel.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

/// Модель лунного дня
///
/// - age: Int - лунный день
/// - sign: EKMoonZodiacSign - лунный знак зодиака
/// - begin: Date? - начало лунного дня
/// - finish: Date? - окончание лунного дня
public class EKMoonModel {

    /// лунный день
    public var age: Int

    /// лунный знак зодиака
    public var sign: EKMoonZodiacSign

    /// восход луны
    public var begin: Date?

    /// заход луны
    public var finish: Date?

    public init(age: Int, sign: EKMoonZodiacSign, begin: Date?, finish: Date?) {
        self.age = age
        self.sign = sign
        self.begin = begin
        self.finish = finish
    }
}
