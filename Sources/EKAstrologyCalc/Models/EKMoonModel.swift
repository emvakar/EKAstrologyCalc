//
//  EKMoonModel.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

/// Модель, представляющая информацию о лунном дне.
public class EKMoonModel {

    /// Лунный день (возраст луны в днях)
    public var age: Int

    /// Лунный знак зодиака
    public var sign: EKMoonZodiacSign

    /// Время начала текущего лунного дня
    public var begin: Date?

    /// Время окончания текущего лунного дня
    public var finish: Date?

    /// Время восхода луны
    public var rise: Date?

    /// Время захода луны
    public var set: Date?

    /// Инициализация модели лунного дня
    /// - Parameters:
    ///   - age: Возраст луны в днях
    ///   - sign: Лунный знак зодиака
    ///   - begin: Дата и время начала лунного дня
    ///   - finish: Дата и время окончания лунного дня
    ///   - rise: Дата и время восхода луны
    ///   - set: Дата и время захода луны
    public init(age: Int, sign: EKMoonZodiacSign, begin: Date?, finish: Date?, rise: Date?, set: Date?) {
        self.age = age
        self.sign = sign
        self.begin = begin
        self.finish = finish
        self.rise = rise
        self.set = set
    }
}
