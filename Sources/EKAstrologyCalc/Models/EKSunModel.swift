//
//  EKSunModel.swift
//  EKSunModel
//
//  Created by Emil Karimov on 28.07.2021.
//

import Foundation

public class EKSunMoonModel {

    /// восход солнца
    public var rise: Date?

    /// заход солнца
    public var set: Date?

    public init(rise: Date?, set: Date?) {
        self.rise = rise
        self.set = set
    }
}
