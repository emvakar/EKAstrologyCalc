//
//  MoonPhase.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit

/// Фазы луны
public enum MoonPhase: String {
    case newMoon
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case fullMoon
    case waningGibbous
    case lastQuarter
    case waningCrescent

    var title: String {
        switch self {
        case .newMoon:
            return R.string.localizable.newMoon()
        case .waxingCrescent:
            return R.string.localizable.waxingCrescent()
        case .firstQuarter:
            return R.string.localizable.firstQuarter()
        case .waxingGibbous:
            return R.string.localizable.waxingGibbous()
        case .fullMoon:
            return R.string.localizable.fullMoon()
        case .waningGibbous:
            return R.string.localizable.waningGibbous()
        case .lastQuarter:
            return R.string.localizable.lastQuarter()
        case .waningCrescent:
            return R.string.localizable.waningCrescent()
        }
    }

    public var icon: UIImage? { return UIImage(named: "\(self.rawValue)") }
}
