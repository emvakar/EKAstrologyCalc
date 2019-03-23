//
//  MoonZodiacSign.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 06/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit

/// Лунный знак зодиака
public enum MoonZodiacSign: String {
    case aries
    case cancer
    case taurus
    case leo
    case gemini
    case virgo
    case libra
    case capricorn
    case scorpio
    case aquarius
    case sagittarius
    case pisces

    public var title: String {
        switch self {
        case .aries:
            return R.string.localizable.aries()
        case .cancer:
            return R.string.localizable.cancer()
        case .taurus:
            return R.string.localizable.taurus()
        case .leo:
            return R.string.localizable.leo()
        case .gemini:
            return R.string.localizable.gemini()
        case .virgo:
            return R.string.localizable.virgo()
        case .libra:
            return R.string.localizable.libra()
        case .capricorn:
            return R.string.localizable.capricorn()
        case .scorpio:
            return R.string.localizable.scorpio()
        case .aquarius:
            return R.string.localizable.aquarius()
        case .sagittarius:
            return R.string.localizable.sagittarius()
        case .pisces:
            return R.string.localizable.pisces()
        }
    }
    public var icon: UIImage? { return UIImage(named: "girl\(self.rawValue.capitalized)") }
    public var iconMini: UIImage? {  return UIImage(named: "sign\(self.rawValue.capitalized)") }
}
