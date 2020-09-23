//
//  MoonZodiacSignCalculator.swift
//  EKAstrologyCalc
//
//  Created by Vasile Morari on 23.09.2020.
//

import Foundation

public final class MoonZodiacSignCalculator {
    
    ///Получить знак зодиака для луны
    public func getMoonZodicaSign(date: Date) -> EKMoonZodiacSign {
        var longitude: Double = 0.0
        var zodiac: EKMoonZodiacSign
        
        var yy: Double = 0.0
        var mm: Double = 0.0
        var k1: Double = 0.0
        var k2: Double = 0.0
        var k3: Double = 0.0
        var jd: Double = 0.0
        var ip: Double = 0.0
        var dp: Double = 0.0
        var rp: Double = 0.0
        
        let year: Double = Double(Calendar.current.component(.year, from: date))
        let month: Double = Double(Calendar.current.component(.month, from: date))
        let day: Double = Double(Calendar.current.component(.day, from: date))
        
        yy = year - floor((12 - month) / 10)
        mm = month + 9.0
        if (mm >= 12) {
            mm = mm - 12
        }
        
        k1 = floor(365.25 * (yy + 4712))
        k2 = floor(30.6 * mm + 0.5)
        k3 = floor(floor((yy / 100) + 49) * 0.75) - 38
        
        jd = k1 + k2 + day + 59
        if (jd > 2299160) {
            jd = jd - k3
        }
        
        ip = ((jd - 2451550.1) / 29.530588853).normalized
        
        ip = ip * 2 * .pi
        
        dp = 2 * .pi * ((jd - 2451562.2) / 27.55454988).normalized
        
        rp = ((jd - 2451555.8) / 27.321582241).normalized
        longitude = 360 * rp + 6.3 * sin(dp) + 1.3 * sin(2 * ip - dp) + 0.7 * sin(2 * ip)
        
        if (longitude < 33.18) {
            zodiac = .aries
        } else if (longitude < 51.16) {
            zodiac = .taurus
        } else if (longitude < 93.44) {
            zodiac = .gemini
        } else if (longitude < 119.48) {
            zodiac = .cancer
        } else if (longitude < 135.30) {
            zodiac = .leo
        } else if (longitude < 173.34) {
            zodiac = .virgo
        } else if (longitude < 224.17) {
            zodiac = .libra
        } else if (longitude < 242.57) {
            zodiac = .scorpio
        } else if (longitude < 271.26) {
            zodiac = .sagittarius
        } else if (longitude < 302.49) {
            zodiac = .capricorn
        } else if (longitude < 311.72) {
            zodiac = .aquarius
        } else if (longitude < 348.58) {
            zodiac = .pisces
        } else {
            zodiac = .aries
        }
        
        return zodiac

    }
}
