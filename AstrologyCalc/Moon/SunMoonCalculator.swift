//
//  SunMoonCalculator.swift
//  AstrologyCalc
//
//  Created by Emil Karimov on 05/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

extension FloatingPoint {
    /* Convert to degrees from radians*/
    var toDegrees:Self { return self * 180 / .pi }
    /* Convert to radians from degrees*/
    var toRadians:Self { return self * .pi / 180 }
}

/** A very simple Sun/Moon calculator without using JPARSEC library
    - author: [Deep Pradhan](https://deeppradhan.heliohost.org)
    - note: Swift port of the excellent [ephemerides (in Java)](http://conga.oan.es/~alonso/doku.php?id=blog:sun_moon_position) by Tomás Alonso Albi*/
public class SunMoonCalculator {

    /** Create instance of Sun/Moon Calculator
    - parameters:
        - date:    The date/time of observations (local timezone)
        - longitude:    Longitude of observation (degrees)
        - latitude:    Latitude of observation (degrees)
    - throws:    invalidJulianDay if the date does not exists*/
    public init(date: Date, longitude: Double, latitude: Double) throws {
        if longitude.isNaN || latitude.isNaN || abs(longitude) > 180 || abs(latitude) > 90 {
            throw Errors.invalidLocation(longitude: longitude, latitude: latitude)
        }
        var calendar:Calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(abbreviation: "UTC")!
        let dc:DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date),
                year:Int = dc.year!,
                month:Int = dc.month!,
                day:Int = dc.day!,
                h:Int = dc.hour!,
                m:Int = dc.minute!,
                s:Int = dc.second!

        // The conversion formulas are from Meeus, chapter 7.
        var julian:Bool = false
        if year < 1582 || (year == 1582 && month <= 10) || (year == 1582 && month == 10 && day < 15) {
            julian = true
        }
        let D:Int = day
        var M:Int = month,
                Y:Int = year
        if M < 3 {
            Y -= 1
            M += 12
        }
        let A:Int = Y / 100,
                B:Int = julian ? 0:2 - A + A / 4,
                dayFraction:Double = (Double(h) + (Double(m) + (Double(s) / 60)) / 60) / 24,
                jd:Double = dayFraction + Double(Int(365.25 * Double(Y + 4716)) + Int(30.6001 * Double(M + 1))) + Double(D + B) - 1524.5

        if jd < 2299160 && jd >= 2299150 {
            throw Errors.invalidJulianDay(jd: jd)
        }

        TTminusUT = 0
        if year > -600 && year < 2200 {
            let x:Double = Double(year) + (Double(month) - 1 + Double(day) / 30) / 12
            let x2:Double = x * x, x3:Double = x2 * x, x4:Double = x3 * x
            if year < 1600 {
                TTminusUT = 10535.328003326353 - 9.995238627481024 * x + 0.003067307630020489 * x2 - 7.76340698361363E-6 * x3 + 3.1331045394223196E-9 * x4 +
                        8.225530854405553E-12 * x2 * x3 - 7.486164715632051E-15 * x4 * x2 + 1.9362461549678834E-18 * x4 * x3 - 8.489224937827653E-23 * x4 * x4
            } else {
                TTminusUT = -1027175.3477559977 + 2523.256625418965 * x - 1.885686849058459 * x2 + 5.869246227888417E-5 * x3 + 3.3379295816475025E-7 * x4 +
                        1.7758961671447929E-10 * x2 * x3 - 2.7889902806153024E-13 * x2 * x4 + 1.0224295822336825E-16 * x3 * x4 - 1.2528102370680435E-20 * x4 * x4
            }
        }
        obsLon = longitude.toRadians
        obsLat = latitude.toRadians
        sunAzimuth = Double.nan
        sunElevation = Double.nan
        sunRise = Double.nan
        sunSet = Double.nan
        sunTransit = Double.nan
        sunTransitElevation = Double.nan
        sunDistance = Double.nan
        moonAzimuth = Double.nan
        moonElevation = Double.nan
        moonRise = Double.nan
        moonSet = Double.nan
        moonTransit = Double.nan
        moonTransitElevation = Double.nan
        moonDistance = Double.nan
        moonAge = Double.nan
        moonIllumination = Double.nan
        moonP = Double.nan
        moonBL = Double.nan
        moonPar = Double.nan
        setUTDate(jd)
    }

    /** Sets the rise/set times to return. Default is for the local horizon*/
    func setTwilight(_ t:Twilight) {
        self.twilight = t
    }

    /** Calculates everything for the Sun and the Moon*/
    func calcSunAndMoon() {
        let jd:Double = self.jd_UT

        // First the Sun
        var out:[Double] = doCalc(getSun())
        sunAzimuth = out[0]
        sunElevation = out[1]
        sunRise = out[2]
        sunSet = out[3]
        sunTransit = out[4]
        sunTransitElevation = out[5]
        let sunRA:Double = out[6], sunDec:Double = out[7]
        sunDistance = out[8]
        let sa:Double = sanomaly, sl:Double = slongitude, lst:Double = out[9]

        var niter:Int = 3 // Number of iterations to get accurate rise/set/transit times
        sunRise = obtainAccurateRiseSetTransit(riseSetJD: sunRise, index: 2, niter: niter, sun: true)
        sunSet = obtainAccurateRiseSetTransit(riseSetJD: sunSet, index: 3, niter: niter, sun: true)
        sunTransit = obtainAccurateRiseSetTransit(riseSetJD: sunTransit, index: 4, niter: niter, sun: true)
        if sunTransit == -1 {
            sunTransitElevation = 0
        } else {
            // Update Sun's maximum elevation
            setUTDate(sunTransit)
            out = doCalc(getSun())
            sunTransitElevation = out[5]
        }

        // Now Moon
        setUTDate(jd)
        sanomaly = sa
        slongitude = sl
        out = doCalc(getMoon())
        moonAzimuth = out[0]
        moonElevation = out[1]
        moonRise = out[2]
        moonSet = out[3]
        moonTransit = out[4]
        moonTransitElevation = out[5]
        let moonRA = out[6],
                moonDec = out[7]
        moonDistance = out[8]
        moonIllumination = (1 - cos(acos(sin(sunDec) * sin(moonDec) + cos(sunDec) * cos(moonDec) * cos(moonRA - sunRA)))) * 0.5
        let ma:Double = moonAge

        niter = 5 // Number of iterations to get accurate rise/set/transit times
        moonRise = obtainAccurateRiseSetTransit(riseSetJD: moonRise, index: 2, niter: niter, sun: false)
        moonSet = obtainAccurateRiseSetTransit(riseSetJD: moonSet, index: 3, niter: niter, sun: false)
        moonTransit = obtainAccurateRiseSetTransit(riseSetJD: moonTransit, index: 4, niter: niter, sun: false)
        if moonTransit == -1 {
            moonTransitElevation = 0
        } else {
            // Update Moon's maximum elevation
            setUTDate(moonTransit)
            var _ = getSun()
            out = doCalc(getMoon())
            moonTransitElevation = out[5]
        }
        setUTDate(jd)
        sanomaly = sa
        slongitude = sl
        moonAge = ma

        out = getMoonDiskOrientationAngles(lst: lst, sunRA: sunRA, sunDec: sunDec,
                moonLon: moonAzimuth.toRadians, moonLat: moonElevation.toRadians, moonRA: moonRA, moonDec: moonDec)
        moonP = out[2]
        moonBL = out[3]
        moonPar = out[4]
    }

    /** Transforms a Julian day (rise/set/transit fields) to a Date
    - parameter jd:    Julian day
    - returns:    Date for specified Julian day
    - throws:    invalidJulianDay if the date does not exists*/
    public static func getDate(jd:Double) throws -> Date {
        if jd.isNaN || (jd < 2299160 && jd >= 2299150) {
            throw Errors.invalidJulianDay(jd: jd)
        }

        // The conversion formulas are from Meeus, Chapter 7.
        let Z:Double = floor(jd + 0.5),
                F:Double = jd + 0.5 - Z
        var A:Double = Z
        if Z >= 2299161 {
            let a:Int = Int((Z - 1867216.25) / 36524.25)
            A += 1 + Double(a) - Double(a) / 4
        }
        let B:Double = A + 1524,
                C:Int = Int((B - 122.1) / 365.25),
                D:Int = Int(Double(C) * 365.25),
                E:Int = Int((B - Double(D)) / 30.6001),
                exactDay:Double = F + B - Double(D) - Double(Int(30.6001 * Double(E))),
                day:Int = Int(exactDay),
                month:Int = (E < 14) ? E - 1:E - 13
        var year:Int = C - 4715
        if month > 2 {
            year -= 1
        }
        let h:Double = ((exactDay - Double(day)) * SunMoonCalculator.SECONDS_PER_DAY) / 3600,
                hour:Int = Int(h),
                m:Double = (h - Double(hour)) * 60,
                minute:Int = Int(m),
                second:Int = Int((m - Double(minute)) * 60)

        var calendar:Calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(abbreviation: "UTC")!
        let date:Date = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second))!
        return calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date))!
    }

    /** Method to return the phase of the Moon as per Moon Age (days)
    - parameter lunarAge:    Lunar age in days
    - returns:    Phase of the Moon*/
    static func getMoonPhaseName(lunarAge:Double) -> String {
        if lunarAge >= 0 && lunarAge <= LUNAR_CYCLE_DAYS && (lunarAge < 1 || lunarAge > LUNAR_CYCLE_DAYS - 1) {
            return "New Moon"
        } else if lunarAge >= 1 && lunarAge < 6.4 {
            return "Waxing Crescent"
        } else if lunarAge >= 6.4 && lunarAge < 8.4 {
            return "First Quarter"
        } else if lunarAge >= 8.4 && lunarAge < 13.8 {
            return "Waxing Gibbous"
        } else if lunarAge >= 13.8 && lunarAge < 15.8 {
            return "Full Moon"
        } else if lunarAge >= 15.8 && lunarAge < 21.1 {
            return "Waning Gibbous"
        } else if lunarAge >= 21.1 && lunarAge < 23.1 {
            return "Last/Third Quarter"
        } else if lunarAge >= 23.1 && lunarAge <= LUNAR_CYCLE_DAYS - 1 {
            return "Waning Crescent"
        } else {
            return "-"
        }
    }

    /** Reduce an angle in radians to the range (0 - 2 Pi)
    - parameter r:    Angle in radians
    - returns:    Reduced angle in radians*/
    private static func normalizeRadians(_ r:Double) -> Double {
        var r:Double = r
        if r < 0 && r >= -2 * Double.pi {
            return r + 2 * Double.pi
        }
        if r >= 2 * Double.pi && r < 4 * Double.pi {
            return r - 2 * Double.pi
        }
        if r >= 0 && r < 2 * Double.pi {
            return r
        }

        r -= 2 * Double.pi * floor(r * 1 / (2 * Double.pi))
        if r < 0 {
            r += 2 * Double.pi
        }

        return r
    }

    private func setUTDate(_ jd:Double) {
        self.jd_UT = jd
        self.t = (jd + TTminusUT / SunMoonCalculator.SECONDS_PER_DAY - SunMoonCalculator.J2000) / SunMoonCalculator.JULIAN_DAYS_PER_CENTURY
    }

    private func getSun() -> [Double] {
        // SUN PARAMETERS (Formulae from "Calendrical Calculations")
        let lon:Double = (280.46645 + 36000.76983 * t + 0.0003032 * t * t),
                anom:Double = (357.5291 + 35999.0503 * t - 0.0001559 * t * t - 4.8E-07 * t * t * t)
        sanomaly = anom.toRadians
        var c:Double = (1.9146 - 0.004817 * t - 0.000014 * t * t) * sin(sanomaly)
        c = c + (0.019993 - 0.000101 * t) * sin(2 * sanomaly)
        c = c + 0.00029 * sin(3 * sanomaly) // Correction to the mean ecliptic longitude

        // Now, let calculate nutation and aberration
        let M1:Double = (124.90 - 1934.134 * t + 0.002063 * t * t).toRadians,
                M2:Double = (201.11 + 72001.5377 * t + 0.00057 * t * t).toRadians,
                d:Double = -0.00569 - 0.0047785 * sin(M1) - 0.0003667 * sin(M2)

        slongitude = lon + c + d // apparent longitude (error<0.003 deg)
        let slatitude:Double = 0, // Sun's ecliptic latitude is always negligible
                ecc:Double = 0.016708617 - 4.2037E-05 * t - 1.236E-07 * t * t, // Eccentricity
                v:Double = sanomaly + c.toRadians, // True anomaly
                sdistance:Double = 1.000001018 * (1 - ecc * ecc) / (1 + ecc * cos(v)) // In UA

        return [slongitude, slatitude, sdistance, atan(696000 / (SunMoonCalculator.AU * sdistance))]
    }

    private func getMoon() -> [Double] {
        // MOON PARAMETERS (Formulae from "Calendrical Calculations")
        let phase:Double = SunMoonCalculator.normalizeRadians((297.8502042 + 445267.1115168 * t - 0.00163 * t * t + t * t * t / 538841 - t * t * t * t / 65194000).toRadians)

        // Anomalistic phase
        var anomaly:Double = (134.9634114 + 477198.8676313 * t + 0.008997 * t * t + t * t * t / 69699 - t * t * t * t / 14712000)
        anomaly = anomaly.toRadians

        // Degrees from ascending node
        var node:Double = (93.2720993 + 483202.0175273 * t - 0.0034029 * t * t - t * t * t / 3526000 + t * t * t * t / 863310000)
        node = node.toRadians

        let E:Double = 1 - (0.002495 + 7.52E-06 * (t + 1)) * (t + 1)

        // Now longitude, with the three main correcting terms of evection,
        // variation, and equation of year, plus other terms (error<0.01 deg)
        // P. Duffet's MOON program taken as reference
        var l:Double = (218.31664563 + 481267.8811958 * t - 0.00146639 * t * t + t * t * t / 540135.03 - t * t * t * t / 65193770.4)
        l += 6.28875 * sin(anomaly) + 1.274018 * sin(2 * phase - anomaly) + 0.658309 * sin(2 * phase)
        l += 0.213616 * sin(2 * anomaly) - E * 0.185596 * sin(sanomaly) - 0.114336 * sin(2 * node)
        l += 0.058793 * sin(2 * phase - 2 * anomaly) + 0.057212 * E * sin(2 * phase - anomaly - sanomaly) + 0.05332 * sin(2 * phase + anomaly)
        l += 0.045874 * E * sin(2 * phase - sanomaly) + 0.041024 * E * sin(anomaly - sanomaly) - 0.034718 * sin(phase) - E * 0.030465 * sin(sanomaly + anomaly)
        l += 0.015326 * sin(2 * (phase - node)) - 0.012528 * sin(2 * node + anomaly) - 0.01098 * sin(2 * node - anomaly) + 0.010674 * sin(4 * phase - anomaly)
        l += 0.010034 * sin(3 * anomaly) + 0.008548 * sin(4 * phase - 2 * anomaly)
        l += -E * 0.00791 * sin(sanomaly - anomaly + 2 * phase) - E * 0.006783 * sin(2 * phase + sanomaly) + 0.005162 * sin(anomaly - phase) + E * 0.005 * sin(sanomaly + phase)
        l += 0.003862 * sin(4 * phase) + E * 0.004049 * sin(anomaly - sanomaly + 2 * phase) + 0.003996 * sin(2 * (anomaly + phase)) + 0.003665 * sin(2 * phase - 3 * anomaly)
        l += E * 2.695E-3 * sin(2 * anomaly - sanomaly) + 2.602E-3 * sin(anomaly - 2*(node+phase))
        l += E * 2.396E-3 * sin(2*(phase - anomaly) - sanomaly) - 2.349E-3 * sin(anomaly+phase)
        l += E * E * 2.249E-3 * sin(2*(phase-sanomaly)) - E * 2.125E-3 * sin(2*anomaly+sanomaly)
        l += -E * E * 2.079E-3 * sin(2*sanomaly) + E * E * 2.059E-3 * sin(2*(phase-sanomaly)-anomaly)
        l += -1.773E-3 * sin(anomaly+2*(phase-node)) - 1.595E-3 * sin(2*(node+phase))
        l += E * 1.22E-3 * sin(4*phase-sanomaly-anomaly) - 1.11E-3 * sin(2*(anomaly+node))
        var longitude:Double = l

        // Let's add nutation here also
        let M1:Double = (124.90 - 1934.134 * t + 0.002063 * t * t).toRadians,
                M2:Double = (201.11 + 72001.5377 * t + 0.00057 * t * t).toRadians,
                d:Double = -0.0047785 * sin(M1) - 0.0003667 * sin(M2)
        longitude += d

        // Get accurate Moon age
        moonAge = SunMoonCalculator.normalizeRadians((longitude - slongitude).toRadians) * SunMoonCalculator.LUNAR_CYCLE_DAYS / (2 * Double.pi)

        // Now Moon parallax
        var parallax:Double = 0.950724 + 0.051818 * cos(anomaly) + 0.009531 * cos(2 * phase - anomaly)
        parallax += 0.007843 * cos(2 * phase) + 0.002824 * cos(2 * anomaly)
        parallax += 0.000857 * cos(2 * phase + anomaly) + E * 0.000533 * cos(2 * phase - sanomaly)
        parallax += E * 0.000401 * cos(2 * phase - anomaly - sanomaly) + E * 0.00032 * cos(anomaly - sanomaly) - 0.000271 * cos(phase)
        parallax += -E * 0.000264 * cos(sanomaly + anomaly) - 0.000198 * cos(2 * node - anomaly)
        parallax += 1.73E-4 * cos(3 * anomaly) + 1.67E-4 * cos(4*phase-anomaly)

        // So Moon distance in Earth radii is, more or less,
        let distance:Double = 1 / sin(parallax.toRadians)

        // Ecliptic latitude with nodal phase (error<0.01 deg)
        l = 5.128189 * sin(node) + 0.280606 * sin(node + anomaly) + 0.277693 * sin(anomaly - node)
        l += 0.173238 * sin(2 * phase - node) + 0.055413 * sin(2 * phase + node - anomaly)
        l += 0.046272 * sin(2 * phase - node - anomaly) + 0.032573 * sin(2 * phase + node)
        l += 0.017198 * sin(2 * anomaly + node) + 0.009267 * sin(2 * phase + anomaly - node)
        l += 0.008823 * sin(2 * anomaly - node) + E * 0.008247 * sin(2 * phase - sanomaly - node) + 0.004323 * sin(2 * (phase - anomaly) - node)
        l += 0.0042 * sin(2 * phase + node + anomaly) + E * 0.003372 * sin(node - sanomaly - 2 * phase)
        l += E * 2.472E-3 * sin(2 * phase + node - sanomaly - anomaly)
        l += E * 2.222E-3 * sin(2 * phase + node - sanomaly)
        l += E * 2.072E-3 * sin(2 * phase - node - sanomaly - anomaly)
        let latitude:Double = l

        return [longitude, latitude, distance * SunMoonCalculator.EARTH_RADIUS / SunMoonCalculator.AU, atan(1737.4 / (distance * SunMoonCalculator.EARTH_RADIUS))]
    }

    private func doCalc(_ pos:[Double]) -> [Double] {
        var pos:[Double] = pos
        // Ecliptic to equatorial coordinates
        let t2:Double = self.t / 100
        var tmp:Double = t2 * (27.87 + t2 * (5.79 + t2 * 2.45))
        tmp = t2 * (-249.67 + t2 * (-39.05 + t2 * (7.12 + tmp)))
        tmp = t2 * (-1.55 + t2 * (1999.25 + t2 * (-51.38 + tmp)))
        tmp = (t2 * (-4680.93 + tmp)) / 3600
        var angle:Double = (23.4392911111111 + tmp).toRadians // obliquity

        // Add nutation in obliquity
        let M1:Double = (124.90 - 1934.134 * t + 0.002063 * t * t).toRadians,
                M2:Double = (201.11 + 72001.5377 * t + 0.00057 * t * t).toRadians,
                d:Double = 0.002558 * cos(M1) - 0.00015339 * cos(M2)
        angle += d.toRadians

        pos[0] = pos[0].toRadians
        pos[1] = pos[1].toRadians
        let cl:Double = cos(pos[1]),
                x:Double = pos[2] * cos(pos[0]) * cl
        var y:Double = pos[2] * sin(pos[0]) * cl,
                z:Double = pos[2] * sin(pos[1])
        tmp = y * cos(angle) - z * sin(angle)
        z = y * sin(angle) + z * cos(angle)
        y = tmp

        // Obtain local apparent sidereal time
        let jd0:Double = floor(jd_UT - 0.5) + 0.5,
                T0:Double = (jd0 - SunMoonCalculator.J2000) / SunMoonCalculator.JULIAN_DAYS_PER_CENTURY,
                secs:Double = (jd_UT - jd0) * SunMoonCalculator.SECONDS_PER_DAY
        var gmst:Double = (((((-6.2e-6 * T0) + 9.3104e-2) * T0) + 8640184.812866) * T0) + 24110.54841
        let msday:Double = 1 + (((((-1.86e-5 * T0) + 0.186208) * T0) + 8640184.812866) / (SunMoonCalculator.SECONDS_PER_DAY * SunMoonCalculator.JULIAN_DAYS_PER_CENTURY))
        gmst = (gmst + msday * secs) * (15 / 3600).toRadians
        let lst:Double = gmst + obsLon

        // Obtain topocentric rectangular coordinates
        // Set radiusAU = 0 for geocentric calculations
        // (rise/set/transit will have no sense in this case)
        let radiusAU:Double = SunMoonCalculator.EARTH_RADIUS / SunMoonCalculator.AU
        let correction:[Double] = [
            radiusAU * cos(obsLat) * cos(lst),
            radiusAU * cos(obsLat) * sin(lst),
            radiusAU * sin(obsLat)]
        let xtopo:Double = x - correction[0],
                ytopo:Double = y - correction[1],
                ztopo:Double = z - correction[2]

        // Obtain topocentric equatorial coordinates
        var ra:Double = 0,
                dec:Double = Double.pi / 2
        if ztopo < 0 {
            dec = -dec
        }
        if ytopo != 0 || xtopo != 0 {
            ra = atan2(ytopo, xtopo)
            dec = atan2(ztopo / sqrt(xtopo * xtopo + ytopo * ytopo), 1)
        }
        let dist:Double = sqrt(xtopo * xtopo + ytopo * ytopo + ztopo * ztopo)

        // Hour angle
        let angh:Double = lst - ra

        // Obtain azimuth and geometric alt
        let sinlat:Double = sin(obsLat),
                coslat:Double = cos(obsLat),
                sindec:Double = sin(dec), cosdec:Double = cos(dec),
                h:Double = sinlat * sindec + coslat * cosdec * cos(angh)
        var alt:Double = asin(h)
        let azy:Double = sin(angh),
                azx:Double = cos(angh) * sinlat - sindec * coslat / cosdec,
                azi:Double = Double.pi + atan2(azy, azx) // 0 = north

        // Get apparent elevation
        if alt > -3.toRadians {
            let r:Double = 0.016667.toRadians * abs(tan(Double.pi / 2 - (alt.toDegrees +  7.31 / (alt.toDegrees + 4.4)).toRadians))
            let refr:Double = r * ( 0.28 * 1010 / (10 + 273)) // Assuming pressure of 1010 mb and T = 10 C
            alt = min(alt + refr, Double.pi / 2) // This is not accurate, but acceptable
        }

        switch twilight {
            case .Horizon34arcmin:
                // Rise, set, transit times, taking into account Sun/Moon angular radius (pos[3]).
                // The 34' factor is the standard refraction at horizon.
                // Removing angular radius will do calculations for the center of the disk instead
                // of the upper limb.
                tmp = -(34 / 60).toRadians - pos[3]
            case .Civil:
                tmp = -6.toRadians
            case .Nautical:
                tmp = -12.toRadians
            case .Astronomical:
                tmp = -18.toRadians
        }

        // Compute cosine of hour angle
        tmp = (sin(tmp) - sin(obsLat) * sin(dec)) / (cos(obsLat) * cos(dec))
        let celestialHoursToEarthTime:Double = 180 / (15 * Double.pi) / 24 / SunMoonCalculator.SIDEREAL_DAY_LENGTH

        // Make calculations for the meridian
        let transit_time1:Double = celestialHoursToEarthTime * SunMoonCalculator.normalizeRadians(ra - lst),
                transit_time2:Double = celestialHoursToEarthTime * (SunMoonCalculator.normalizeRadians(ra - lst) - 2 * Double.pi)
        var transit_alt:Double = asin(sin(dec) * sin(obsLat) + cos(dec) * cos(obsLat))
        if transit_alt > -3.toRadians {
            let r:Double = 0.016667.toRadians * abs(tan(Double.pi / 2 - (transit_alt.toDegrees +  7.31 / (transit_alt.toDegrees + 4.4)).toRadians)),
                    refr:Double = r * ( 0.28 * 1010 / (10 + 273)) // Assuming pressure of 1010 mb and T = 10 C
            transit_alt = min(transit_alt + refr, Double.pi / 2) // This is not accurate, but acceptable
        }

        // Obtain the current event in time
        var transit_time:Double = transit_time1
        let jdToday:Double = floor(jd_UT - 0.5) + 0.5,
                transitToday2:Double = floor(jd_UT + transit_time2 - 0.5) + 0.5
        // Obtain the transit time. Preference should be given to the closest event
        // in time to the current calculation time
        if jdToday == transitToday2 && abs(transit_time2) < abs(transit_time1) {
            transit_time = transit_time2
        }
        let transit:Double = jd_UT + transit_time

        // Make calculations for rise and set
        var rise:Double = -1, set:Double = -1
        if abs(tmp) <= 1 {
            let ang_hor:Double = abs(acos(tmp)),
                    rise_time1:Double = celestialHoursToEarthTime * SunMoonCalculator.normalizeRadians(ra - ang_hor - lst),
                    set_time1:Double = celestialHoursToEarthTime * SunMoonCalculator.normalizeRadians(ra + ang_hor - lst),
                    rise_time2:Double = celestialHoursToEarthTime * (SunMoonCalculator.normalizeRadians(ra - ang_hor - lst) - 2 * Double.pi),
                    set_time2:Double = celestialHoursToEarthTime * (SunMoonCalculator.normalizeRadians(ra + ang_hor - lst) - 2 * Double.pi)

            // Obtain the current events in time. Preference should be given to the closest event
            // in time to the current calculation time (so that iteration in other method will converge)
            var rise_time:Double = rise_time1
            let riseToday2:Double = floor(jd_UT + rise_time2 - 0.5) + 0.5
            if jdToday == riseToday2 && abs(rise_time2) < abs(rise_time1) {
                rise_time = rise_time2
            }

            var set_time:Double = set_time1
            let setToday2:Double = floor(jd_UT + set_time2 - 0.5) + 0.5
            if jdToday == setToday2 && abs(set_time2) < abs(set_time1) {
                set_time = set_time2
            }
            rise = jd_UT + rise_time
            set = jd_UT + set_time
        }

        return [azi, alt, rise, set, transit, transit_alt, ra, dec, dist, lst]
    }

    private func obtainAccurateRiseSetTransit(riseSetJD:Double, index:Int, niter:Int, sun:Bool) -> Double {
        var riseSetJD:Double = riseSetJD,
                step:Double = -1
        for _ in 0..<niter {
            if riseSetJD == -1 {
                return riseSetJD // -1 means no rise/set from that location
            }
            setUTDate(riseSetJD)
            var out:[Double]
            if sun {
                out = doCalc(getSun())
            } else {
                var _ = getSun()
                out = doCalc(getMoon())
            }
            step = abs(riseSetJD - out[index])
            riseSetJD = out[index]
        }
        if step > 1 / SunMoonCalculator.SECONDS_PER_DAY {
            return -1 // did not converge => without rise/set/transit in this date
        }
        return riseSetJD
    }

    /** Method to calculate values of Moon Disk
    - returns:    [optical librations (lp), lunar coordinates of the centre of the disk (bp),
    position angle of axis (p), bright limb angle (bl), paralactic angle (par)]*/
    private func getMoonDiskOrientationAngles(lst:Double, sunRA:Double, sunDec:Double,
            moonLon:Double, moonLat:Double, moonRA:Double, moonDec:Double) -> [Double] {
        // Moon's argument of latitude
        let F:Double = (93.2720993 + 483202.0175273 * t - 0.0034029 * t * t
                - t * t * t / 3526000 + t * t * t * t / 863310000).toRadians
        // Moon's inclination
        let I:Double = (1.54242).toRadians
        // Moon's mean ascending node longitude
        let omega:Double = (125.0445550 - 1934.1361849 * t + 0.0020762 * t * t
                + t * t * t / 467410 - t * t * t * t / 18999000).toRadians
        // Obliquity of ecliptic (approx, better formulae up)
        let eps:Double = (23.43929).toRadians

        // Obtain optical librations lp and bp
        let W:Double = moonLon - omega,
                sinA:Double = sin(W) * cos(moonLat) * cos(I) - sin(moonLat) * sin(I),
                cosA:Double = cos(W) * cos(moonLat),
                A:Double = atan2(sinA, cosA),
                lp:Double = SunMoonCalculator.normalizeRadians(A - F),
                sinbp:Double = -sin(W) * cos(moonLat) * sin(I) - sin(moonLat) * cos(I),
                bp:Double = asin(sinbp)

        // Obtain position angle of axis p
        var x:Double = sin(I) * sin(omega),
                y:Double = sin(I) * cos(omega) * cos(eps) - cos(I) * sin(eps)
        let w:Double = atan2(x, y),
                sinp:Double = sqrt(x * x + y * y) * cos(moonRA - w) / cos(bp),
                p:Double = asin(sinp)

        // Compute bright limb angle bl
        let bl:Double = (Double.pi + atan2(cos(sunDec) * sin(moonRA - sunRA), cos(sunDec)
                * sin(moonDec) * cos(moonRA - sunRA) - sin(sunDec) * cos(moonDec)))

        // Paralactic angle par
        y = sin(lst - moonRA)
        x = tan(obsLat) * cos(moonDec) - sin(moonDec) * cos(lst - moonRA)
        let par:Double = x != 0 ? atan2(y, x):(y / abs(y)) * Double.pi / 2

        return [lp, bp, p, bl, par]
    }

    /** Astronomical Unit in km. As defined by JPL*/
    static let AU:Double = 149597870.691

    /** Earth equatorial radius in km. IERS 2003 Conventions*/
    static let EARTH_RADIUS:Double = 6378.1366

    /** Length of a sidereal day in days according to IERS Conventions*/
    static let SIDEREAL_DAY_LENGTH:Double = 1.00273781191135448

    /** Julian century conversion constant = 100 * days per year*/
    static let JULIAN_DAYS_PER_CENTURY:Double = 36525

    /** Seconds in one day*/
    static let SECONDS_PER_DAY:Double = 86400

    /** Our default epoch.<br>
    The Julian Day which represents noon on 2000-01-01*/
    static let J2000:Double = 2451545

    /** Lunar cycle length in days*/
    static let LUNAR_CYCLE_DAYS:Double = 29.530588853

    /** The set of twilights to calculate (types of rise/set events)*/
    enum Twilight {
        /** Event ID for calculation of rising and setting times for astronomical
        twilight. In this case, the calculated time will be the time when the
        center of the object is at -18 degrees of geometrical elevation below the
        astronomical horizon. At this time astronomical observations are possible
        because the sky is dark enough*/
        case Astronomical
        /** Event ID for calculation of rising and setting times for nautical
        twilight. In this case, the calculated time will be the time when the
        center of the object is at -12 degrees of geometric elevation below the
        astronomical horizon*/
        case Nautical
        /** Event ID for calculation of rising and setting times for civil twilight.
        In this case, the calculated time will be the time when the center of the
        object is at -6 degrees of geometric elevation below the astronomical
        horizon*/
        case Civil
        /** The standard value of 34' for the refraction at the local horizon*/
        case Horizon34arcmin
    }

    /** Error types which can be thrown*/
    enum Errors: Error {
        /** Julian day does not exists*/
        case invalidJulianDay(jd: Double)
        /** Invalid location*/
        case invalidLocation(longitude: Double, latitude: Double)
    }

    /** Input values*/
    private var jd_UT: Double = 0, t: Double = 0, obsLon: Double = 0, obsLat: Double = 0, TTminusUT: Double = 0,
        twilight: Twilight = Twilight.Horizon34arcmin, slongitude: Double = 0, sanomaly: Double = 0

    /** Sun azimuth (radians)*/
    public var sunAzimuth:Double
    /** Sun elevation (radians)*/
    public var sunElevation:Double
    /** Sun rise (Julian days as per UTC)*/
    public var sunRise:Double
    /** Sun set (Julian days as per UTC)*/
    public var sunSet:Double
    /** Sun transit (Julian days as per UTC)*/
    public var sunTransit:Double
    /** Sun transit elevation (radians)*/
    public var sunTransitElevation:Double
    /** Sun distance (AUs)*/
    public var sunDistance:Double

    /** Moon azimuth (radians)*/
    public var moonAzimuth:Double
    /** Moon elevation (radians)*/
    public var moonElevation:Double
    /** Moon rise (Julian days as per UTC)*/
    public var moonRise:Double
    /** Moon set (Julian days as per UTC)*/
    public var moonSet:Double
    /** Moon transit (Julian days as per UTC)*/
    public var moonTransit:Double
    /** Moon transit elevation (radians)*/
    public var moonTransitElevation:Double
    /** Moon distance (AUs)*/
    public var moonDistance:Double
    /** Moon age (days: 0-29.5)*/
    public var moonAge:Double
    /** Moon illumination (percentage)*/
    public var moonIllumination:Double
    /** Moon position angle of axis (radians)*/
    public var moonP:Double
    /** Moon bright limb angle (radians)*/
    public var moonBL:Double
    /** Moon paralactic angle (radians)*/
    public var moonPar:Double
    /** Moon phase as per age*/
    var moonPhase:String {
        return SunMoonCalculator.getMoonPhaseName(lunarAge: moonAge)
    }
}


//
//import UIKit
//
///**
// * http://conga.oan.es/~alonso/doku.php?id=blog:sun_moon_position
// * http://conga.oan.es/%7Ealonso/SunMoonCalculator.swift
// */
//
///**
// * A very simple Sun/Moon calculator without using JPARSEC library.
// * @author T. Alonso Albi - OAN (Spain), email t.alonso@oan.es
// * @version May 25, 2017 (fixed nutation correction and moon age, better accuracy in Moon)
// */
//public class SunMoonCalculator {
//
//    /** Radians to degrees. */
//    static let RAD_TO_DEG: Double = 180.0 / Double.pi
//
//    /** Degrees to radians. */
//    static let DEG_TO_RAD: Double = 1.0 / RAD_TO_DEG
//
//    /** Radians to hours. */
//    static let RAD_TO_HOUR: Double = 180.0 / (15.0 * Double.pi)
//
//    /** Radians to days. */
//    static let RAD_TO_DAY: Double = RAD_TO_HOUR / 24.0
//
//    /** Astronomical Unit in km. As defined by JPL. */
//    static let AU: Double = 149597870.691
//
//    /** Earth equatorial radius in km. IERS 2003 Conventions. */
//    static let EARTH_RADIUS: Double = 6378.1366
//
//    /** Two times Pi. */
//    static let TWO_PI: Double = 2.0 * Double.pi
//
//    /** The inverse of two times Pi. */
//    static let TWO_PI_INVERSE: Double = 1.0 / (2.0 * Double.pi)
//
//    /** Four times Pi. */
//    static let FOUR_PI: Double = 4.0 * Double.pi
//
//    /** Pi divided by two. */
//    static let PI_OVER_TWO: Double = Double.pi / 2.0
//
//    /** Length of a sidereal day in days according to IERS Conventions. */
//    static let SIDEREAL_DAY_LENGTH: Double = 1.00273781191135448
//
//    /** Julian century conversion constant = 100 * days per year. */
//    static let JULIAN_DAYS_PER_CENTURY: Double = 36525.0
//
//    /** Seconds in one day. */
//    static let SECONDS_PER_DAY: Double = 86400
//
//    /** Our default epoch. <BR>
//     * The Julian Day which represents noon on 2000-01-01. */
//    static let J2000: Double = 2451545.0
//
//    /**
//     * The set of twilights to calculate (types of rise/set events).
//     */
//    enum TWILIGHT {
//        /**
//         * Event ID for calculation of rising and setting times for astronomical
//         * twilight. In this case, the calculated time will be the time when the
//         * center of the object is at -18 degrees of geometrical elevation below the
//         * astronomical horizon. At this time astronomical observations are possible
//         * because the sky is dark enough.
//         */
//        case TWILIGHT_ASTRONOMICAL
//        /**
//         * Event ID for calculation of rising and setting times for nautical
//         * twilight. In this case, the calculated time will be the time when the
//         * center of the object is at -12 degrees of geometric elevation below the
//         * astronomical horizon.
//         */
//        case TWILIGHT_NAUTICAL
//        /**
//         * Event ID for calculation of rising and setting times for civil twilight.
//         * In this case, the calculated time will be the time when the center of the
//         * object is at -6 degrees of geometric elevation below the astronomical
//         * horizon.
//         */
//        case TWILIGHT_CIVIL
//        /**
//         * The standard value of 34' for the refraction at the local horizon.
//         */
//        case HORIZON_34arcmin
//    }
//
//    enum Errors: Error {
//        case invalidJulianDay(jd:Double)
//    }
//
//    /** Input values. */
//    private var jd_UT: Double = 0, t: Double = 0, obsLon: Double = 0, obsLat: Double = 0, TTminusUT: Double = 0
//    private var twilight: TWILIGHT = TWILIGHT.HORIZON_34arcmin
//    private var slongitude: Double = 0, sanomaly: Double = 0
//
//    /** Values for azimuth, elevation, rise, set, and transit for the Sun. Angles in radians, rise ... as Julian days in UT.
//     * Distance in AU. */
//    var sunAz: Double, sunEl: Double, sunRise: Double, sunSet: Double, sunTransit: Double, sunTransitElev: Double, sunDist: Double
//
//    /** Values for azimuth, elevation, rise, set, and transit for the Moon. Angles in radians, rise ... as Julian days in UT.
//     * Moon age is the number of days since last new Moon, in days, from 0 to 29.5. Distance in AU. */
//    public var moonAz: Double, moonEl: Double, moonRise: Double, moonSet: Double, moonTransit: Double, moonAge: Double, moonTransitElev: Double, moonDist: Double
//
//    /// Main constructor for Sun/Moon calculations. Time should be given in
//    /// Universal Time (UT), observer angles in radians.
//    ///
//    /// - Parameters:
//    ///   - year: The year.
//    ///   - month: The month.
//    ///   - day: The day.
//    ///   - h: The hour.
//    ///   - m: Minute.
//    ///   - s: Second.
//    ///   - obsLon: Longitude for the observer.
//    ///   - obsLat: Latitude for the observer.
//    /// - Throws: Exception If the date does not exists.
//    public init(year: Int, month: Int, day: Int, h: Int, m: Int, s: Int, obsLon: Double, obsLat: Double) throws {
//        self.sunAz = Double.nan
//        self.sunEl = Double.nan
//        self.sunRise = Double.nan
//        self.sunSet = Double.nan
//        self.sunTransit = Double.nan
//        self.sunTransitElev = Double.nan
//        self.sunDist = Double.nan
//        self.moonAz = Double.nan
//        self.moonEl = Double.nan
//        self.moonRise = Double.nan
//        self.moonSet = Double.nan
//        self.moonTransit = Double.nan
//        self.moonAge = Double.nan
//        self.moonTransitElev = Double.nan
//        self.moonDist = Double.nan
//
//        // The conversion formulas are from Meeus, chapter 7.
//        var julian: Bool = false
//        if (year < 1582 || (year == 1582 && month <= 10) || (year == 1582 && month == 10 && day < 15)) {
//            julian = true
//        }
//        let D: Int = day
//        var M: Int = month
//        var Y: Int = year
//        if (M < 3) {
//            Y -= 1
//            M += 12
//        }
//        let A: Int = Y / 100
//        let B: Int = julian ? 0:2 - A + A / 4
//
//        let dayFraction: Double = (Double(h) + (Double(m) + (Double(s) / 60.0)) / 60.0) / 24.0
//
//        let jd: Double = dayFraction + Double(Int(365.25 * Double(Y + 4716)) + Int(30.6001 * Double(M + 1))) + Double(D + B) - 1524.5
//
//        if (jd < 2299160.0 && jd >= 2299150.0) {
//            throw SunMoonCalculator.Errors.invalidJulianDay(jd: jd)
//        }
//
//        TTminusUT = 0
//        if (year > -600 && year < 2200) {
//            let x: Double = Double(year) + (Double(month) - 1.0 + Double(day) / 30.0) / 12.0
//            let x2: Double = x * x, x3: Double = x2 * x, x4: Double = x3 * x
//            if (year < 1600) {
//                TTminusUT = 10535.328003326353 - 9.995238627481024 * x + 0.003067307630020489 * x2 - 7.76340698361363E-6 * x3 + 3.1331045394223196E-9 * x4 +
//                    8.225530854405553E-12 * x2 * x3 - 7.486164715632051E-15 * x4 * x2 + 1.9362461549678834E-18 * x4 * x3 - 8.489224937827653E-23 * x4 * x4
//            } else {
//                TTminusUT = -1027175.3477559977 + 2523.256625418965 * x - 1.885686849058459 * x2 + 5.869246227888417E-5 * x3 + 3.3379295816475025E-7 * x4 +
//                    1.7758961671447929E-10 * x2 * x3 - 2.7889902806153024E-13 * x2 * x4 + 1.0224295822336825E-16 * x3 * x4 - 1.2528102370680435E-20 * x4 * x4
//            }
//        }
//        self.obsLon = obsLon
//        self.obsLat = obsLat
//        setUTDate(jd)
//    }
//
//    /// Sets the rise/set times to return. Default is for the local horizon.
//    ///
//    /// - Parameter t: The Twilight.
//    private func setTwilight(_ t: TWILIGHT) {
//        self.twilight = t
//    }
//
//    private func setUTDate(_ jd: Double) {
//        self.jd_UT = jd
//        self.t = (jd + TTminusUT / SunMoonCalculator.SECONDS_PER_DAY - SunMoonCalculator.J2000) / SunMoonCalculator.JULIAN_DAYS_PER_CENTURY
//    }
//
//    /** Calculates everything for the Sun and the Moon. */
//    public func calcSunAndMoon() {
//        let jd: Double = self.jd_UT
//
//        // First the Sun
//        var out: [Double] = doCalc(getSun())
//        sunAz = out[0]
//        sunEl = out[1]
//        sunRise = out[2]
//        sunSet = out[3]
//        sunTransit = out[4]
//        sunTransitElev = out[5]
//        sunDist = out[8]
//        let sa: Double = sanomaly, sl: Double = slongitude
//
//        var niter: Int = 3 // Number of iterations to get accurate rise/set/transit times
//        sunRise = obtainAccurateRiseSetTransit(riseSetJD: sunRise, index: 2, niter: niter, sun: true)
//        sunSet = obtainAccurateRiseSetTransit(riseSetJD: sunSet, index: 3, niter: niter, sun: true)
//        sunTransit = obtainAccurateRiseSetTransit(riseSetJD: sunTransit, index: 4, niter: niter, sun: true)
//        if (sunTransit == -1) {
//            sunTransitElev = 0
//        } else {
//            // Update Sun's maximum elevation
//            setUTDate(sunTransit)
//            out = doCalc(getSun())
//            sunTransitElev = out[5]
//        }
//
//        // Now Moon
//        setUTDate(jd)
//        sanomaly = sa
//        slongitude = sl
//        out = doCalc(getMoon())
//        moonAz = out[0]
//        moonEl = out[1]
//        moonRise = out[2]
//        moonSet = out[3]
//        moonTransit = out[4]
//        moonTransitElev = out[5]
//        moonDist = out[8]
//        let ma: Double = moonAge
//
//        niter = 5 // Number of iterations to get accurate rise/set/transit times
//        moonRise = obtainAccurateRiseSetTransit(riseSetJD: moonRise, index: 2, niter: niter, sun: false)
//        moonSet = obtainAccurateRiseSetTransit(riseSetJD: moonSet, index: 3, niter: niter, sun: false)
//        moonTransit = obtainAccurateRiseSetTransit(riseSetJD: moonTransit, index: 4, niter: niter, sun: false)
//        if (moonTransit == -1) {
//            moonTransitElev = 0
//        } else {
//            // Update Moon's maximum elevation
//            setUTDate(moonTransit)
//            _ = getSun()
//            out = doCalc(getMoon())
//            moonTransitElev = out[5]
//        }
//        setUTDate(jd)
//        sanomaly = sa
//        slongitude = sl
//        moonAge = ma
//    }
//
//    private func getSun() -> [Double] {
//        // SUN PARAMETERS (Formulae from "Calendrical Calculations")
//        let lon: Double = (280.46645 + 36000.76983 * t + 0.0003032 * t * t)
//        let anom: Double = (357.5291 + 35999.0503 * t - 0.0001559 * t * t - 4.8E-07 * t * t * t)
//        sanomaly = anom * SunMoonCalculator.DEG_TO_RAD
//        var c: Double = (1.9146 - 0.004817 * t - 0.000014 * t * t) * sin(sanomaly)
//        c = c + (0.019993 - 0.000101 * t) * sin(2 * sanomaly)
//        c = c + 0.00029 * sin(3.0 * sanomaly) // Correction to the mean ecliptic longitude
//
//        // Now, let calculate nutation and aberration
//        let M1: Double = (124.90 - 1934.134 * t + 0.002063 * t * t) * SunMoonCalculator.DEG_TO_RAD
//        let M2: Double = (201.11 + 72001.5377 * t + 0.00057 * t * t) * SunMoonCalculator.DEG_TO_RAD
//        let d: Double = -0.00569 - 0.0047785 * sin(M1) - 0.0003667 * sin(M2)
//
//        slongitude = lon + c + d // apparent longitude (error<0.003 deg)
//        let slatitude: Double = 0 // Sun's ecliptic latitude is always negligible
//        let ecc: Double = 0.016708617 - 4.2037E-05 * t - 1.236E-07 * t * t // Eccentricity
//        let v: Double = sanomaly + c * SunMoonCalculator.DEG_TO_RAD // True anomaly
//        let sdistance: Double = 1.000001018 * (1.0 - ecc * ecc) / (1.0 + ecc * cos(v)) // In UA
//
//        return [slongitude, slatitude, sdistance, atan(696000 / (SunMoonCalculator.AU * sdistance))]
//    }
//
//    private func getMoon() -> [Double] {
//        // MOON PARAMETERS (Formulae from "Calendrical Calculations")
//        let phase: Double = SunMoonCalculator.normalizeRadians((297.8502042 + 445267.1115168 * t - 0.00163 * t * t + t * t * t / 538841 - t * t * t * t / 65194000) * SunMoonCalculator.DEG_TO_RAD)
//
//        // Anomalistic phase
//        var anomaly: Double = (134.9634114 + 477198.8676313 * t + 0.008997 * t * t + t * t * t / 69699 - t * t * t * t / 14712000)
//        anomaly = anomaly * SunMoonCalculator.DEG_TO_RAD
//
//        // Degrees from ascending node
//        var node: Double = (93.2720993 + 483202.0175273 * t - 0.0034029 * t * t - t * t * t / 3526000 + t * t * t * t / 863310000)
//        node = node * SunMoonCalculator.DEG_TO_RAD
//
//        let E: Double = 1.0 - (0.002495 + 7.52E-06 * (t + 1.0)) * (t + 1.0)
//
//        // Now longitude, with the three main correcting terms of evection,
//        // variation, and equation of year, plus other terms (error<0.01 deg)
//        // P. Duffet's MOON program taken as reference
//        var l: Double = (218.31664563 + 481267.8811958 * t - 0.00146639 * t * t + t * t * t / 540135.03 - t * t * t * t / 65193770.4)
//        l += 6.28875 * sin(anomaly) + 1.274018 * sin(2 * phase - anomaly) + 0.658309 * sin(2 * phase)
//        l += 0.213616 * sin(2 * anomaly) - E * 0.185596 * sin(sanomaly) - 0.114336 * sin(2 * node)
//        l += 0.058793 * sin(2 * phase - 2 * anomaly) + 0.057212 * E * sin(2 * phase - anomaly - sanomaly) + 0.05332 * sin(2 * phase + anomaly)
//        l += 0.045874 * E * sin(2 * phase - sanomaly) + 0.041024 * E * sin(anomaly - sanomaly) - 0.034718 * sin(phase) - E * 0.030465 * sin(sanomaly + anomaly)
//        l += 0.015326 * sin(2 * (phase - node)) - 0.012528 * sin(2 * node + anomaly) - 0.01098 * sin(2 * node - anomaly) + 0.010674 * sin(4 * phase - anomaly)
//        l += 0.010034 * sin(3 * anomaly) + 0.008548 * sin(4 * phase - 2 * anomaly)
//        l += -E * 0.00791 * sin(sanomaly - anomaly + 2 * phase) - E * 0.006783 * sin(2 * phase + sanomaly) + 0.005162 * sin(anomaly - phase) + E * 0.005 * sin(sanomaly + phase)
//        l += 0.003862 * sin(4 * phase) + E * 0.004049 * sin(anomaly - sanomaly + 2 * phase) + 0.003996 * sin(2 * (anomaly + phase)) + 0.003665 * sin(2 * phase - 3 * anomaly)
//        l += E * 2.695E-3 * sin(2 * anomaly - sanomaly) + 2.602E-3 * sin(anomaly - 2*(node+phase))
//        l += E * 2.396E-3 * sin(2*(phase - anomaly) - sanomaly) - 2.349E-3 * sin(anomaly+phase)
//        l += E * E * 2.249E-3 * sin(2*(phase-sanomaly)) - E * 2.125E-3 * sin(2*anomaly+sanomaly)
//        l += -E * E * 2.079E-3 * sin(2*sanomaly) + E * E * 2.059E-3 * sin(2*(phase-sanomaly)-anomaly)
//        l += -1.773E-3 * sin(anomaly+2*(phase-node)) - 1.595E-3 * sin(2*(node+phase))
//        l += E * 1.22E-3 * sin(4*phase-sanomaly-anomaly) - 1.11E-3 * sin(2*(anomaly+node))
//        var longitude: Double = l
//
//        // Let's add nutation here also
//        let M1: Double = (124.90 - 1934.134 * t + 0.002063 * t * t) * SunMoonCalculator.DEG_TO_RAD
//        let M2: Double = (201.11 + 72001.5377 * t + 0.00057 * t * t) * SunMoonCalculator.DEG_TO_RAD
//        let d: Double = -0.0047785 * sin(M1) - 0.0003667 * sin(M2)
//        longitude += d
//
//        // Get accurate Moon age
//        let Psin: Double = 29.530588853
//        moonAge = SunMoonCalculator.normalizeRadians((longitude - slongitude) * SunMoonCalculator.DEG_TO_RAD) * Psin / SunMoonCalculator.TWO_PI
//
//        // Now Moon parallax
//        var parallax: Double = 0.950724 + 0.051818 * cos(anomaly) + 0.009531 * cos(2 * phase - anomaly)
//        parallax += 0.007843 * cos(2 * phase) + 0.002824 * cos(2 * anomaly)
//        parallax += 0.000857 * cos(2 * phase + anomaly) + E * 0.000533 * cos(2 * phase - sanomaly)
//        parallax += E * 0.000401 * cos(2 * phase - anomaly - sanomaly) + E * 0.00032 * cos(anomaly - sanomaly) - 0.000271 * cos(phase)
//        parallax += -E * 0.000264 * cos(sanomaly + anomaly) - 0.000198 * cos(2 * node - anomaly)
//        parallax += 1.73E-4 * cos(3 * anomaly) + 1.67E-4 * cos(4*phase-anomaly)
//
//        // So Moon distance in Earth radii is, more or less,
//        let distance: Double = 1.0 / sin(parallax * SunMoonCalculator.DEG_TO_RAD)
//
//        // Ecliptic latitude with nodal phase (error<0.01 deg)
//        l = 5.128189 * sin(node) + 0.280606 * sin(node + anomaly) + 0.277693 * sin(anomaly - node)
//        l += 0.173238 * sin(2 * phase - node) + 0.055413 * sin(2 * phase + node - anomaly)
//        l += 0.046272 * sin(2 * phase - node - anomaly) + 0.032573 * sin(2 * phase + node)
//        l += 0.017198 * sin(2 * anomaly + node) + 0.009267 * sin(2 * phase + anomaly - node)
//        l += 0.008823 * sin(2 * anomaly - node) + E * 0.008247 * sin(2 * phase - sanomaly - node) + 0.004323 * sin(2 * (phase - anomaly) - node)
//        l += 0.0042 * sin(2 * phase + node + anomaly) + E * 0.003372 * sin(node - sanomaly - 2 * phase)
//        l += E * 2.472E-3 * sin(2 * phase + node - sanomaly - anomaly)
//        l += E * 2.222E-3 * sin(2 * phase + node - sanomaly)
//        l += E * 2.072E-3 * sin(2 * phase - node - sanomaly - anomaly)
//        let latitude: Double = l
//
//        return [longitude, latitude, distance * SunMoonCalculator.EARTH_RADIUS / SunMoonCalculator.AU, atan(1737.4 / (distance * SunMoonCalculator.EARTH_RADIUS))]
//    }
//
//    private func doCalc(_ pos: [Double]) -> [Double] {
//        var pos: [Double] = pos
//        // Ecliptic to equatorial coordinates
//        let t2: Double = self.t / 100.0
//        var tmp: Double = t2 * (27.87 + t2 * (5.79 + t2 * 2.45))
//        tmp = t2 * (-249.67 + t2 * (-39.05 + t2 * (7.12 + tmp)))
//        tmp = t2 * (-1.55 + t2 * (1999.25 + t2 * (-51.38 + tmp)))
//        tmp = (t2 * (-4680.93 + tmp)) / 3600.0
//        var angle: Double = (23.4392911111111 + tmp) * SunMoonCalculator.DEG_TO_RAD // obliquity
//
//        // Add nutation in obliquity
//        let M1: Double = (124.90 - 1934.134 * t + 0.002063 * t * t) * SunMoonCalculator.DEG_TO_RAD
//        let M2: Double = (201.11 + 72001.5377 * t + 0.00057 * t * t) * SunMoonCalculator.DEG_TO_RAD
//        let d: Double = 0.002558 * cos(M1) - 0.00015339 * cos(M2)
//        angle += d * SunMoonCalculator.DEG_TO_RAD
//
//        pos[0] *= SunMoonCalculator.DEG_TO_RAD
//        pos[1] *= SunMoonCalculator.DEG_TO_RAD
//        let cl: Double = cos(pos[1])
//        let x: Double = pos[2] * cos(pos[0]) * cl
//        var y: Double = pos[2] * sin(pos[0]) * cl
//        var z: Double = pos[2] * sin(pos[1])
//        tmp = y * cos(angle) - z * sin(angle)
//        z = y * sin(angle) + z * cos(angle)
//        y = tmp
//
//        // Obtain local apparent sidereal time
//        let jd0: Double = floor(jd_UT - 0.5) + 0.5
//        let T0: Double = (jd0 - SunMoonCalculator.J2000) / SunMoonCalculator.JULIAN_DAYS_PER_CENTURY
//        let secs: Double = (jd_UT - jd0) * SunMoonCalculator.SECONDS_PER_DAY
//        var gmst: Double = (((((-6.2e-6 * T0) + 9.3104e-2) * T0) + 8640184.812866) * T0) + 24110.54841
//        let msday: Double = 1.0 + (((((-1.86e-5 * T0) + 0.186208) * T0) + 8640184.812866) / (SunMoonCalculator.SECONDS_PER_DAY * SunMoonCalculator.JULIAN_DAYS_PER_CENTURY))
//        gmst = (gmst + msday * secs) * (15.0 / 3600.0) * SunMoonCalculator.DEG_TO_RAD
//        let lst: Double = gmst + obsLon
//
//        // Obtain topocentric rectangular coordinates
//        // Set radiusAU = 0 for geocentric calculations
//        // (rise/set/transit will have no sense in this case)
//        let radiusAU: Double = SunMoonCalculator.EARTH_RADIUS / SunMoonCalculator.AU
//        var correction: [Double] = [
//            radiusAU * cos(obsLat) * cos(lst),
//            radiusAU * cos(obsLat) * sin(lst),
//            radiusAU * sin(obsLat)]
//        let xtopo: Double = x - correction[0]
//        let ytopo: Double = y - correction[1]
//        let ztopo: Double = z - correction[2]
//
//        // Obtain topocentric equatorial coordinates
//        var ra: Double = 0.0
//        var dec: Double = SunMoonCalculator.PI_OVER_TWO
//        if (ztopo < 0.0) {
//            dec = -dec
//        }
//        if (ytopo != 0.0 || xtopo != 0.0) {
//            ra = atan2(ytopo, xtopo)
//            dec = atan2(ztopo / sqrt(xtopo * xtopo + ytopo * ytopo), 1.0)
//        }
//        let dist: Double = sqrt(xtopo * xtopo + ytopo * ytopo + ztopo * ztopo)
//
//        // Hour angle
//        let angh: Double = lst - ra
//
//        // Obtain azimuth and geometric alt
//        let sinlat: Double = sin(obsLat)
//        let coslat: Double = cos(obsLat)
//        let sindec: Double = sin(dec), cosdec: Double = cos(dec)
//        let h: Double = sinlat * sindec + coslat * cosdec * cos(angh)
//        var alt: Double = asin(h)
//        let azy: Double = sin(angh)
//        let azx: Double = cos(angh) * sinlat - sindec * coslat / cosdec
//        let azi: Double = Double.pi + atan2(azy, azx) // 0 = north
//
//        // Get apparent elevation
//        if (alt > -3 * SunMoonCalculator.DEG_TO_RAD) {
//            let r: Double = 0.016667 * SunMoonCalculator.DEG_TO_RAD * abs(tan(SunMoonCalculator.PI_OVER_TWO - (alt * SunMoonCalculator.RAD_TO_DEG +  7.31 / (alt * SunMoonCalculator.RAD_TO_DEG + 4.4)) * SunMoonCalculator.DEG_TO_RAD))
//            let refr: Double = r * ( 0.28 * 1010 / (10 + 273.0)) // Assuming pressure of 1010 mb and T = 10 C
//            alt = min(alt + refr, SunMoonCalculator.PI_OVER_TWO) // This is not accurate, but acceptable
//        }
//
//        switch twilight {
//        case .HORIZON_34arcmin:
//            // Rise, set, transit times, taking into account Sun/Moon angular radius (pos[3]).
//            // The 34' factor is the standard refraction at horizon.
//            // Removing angular radius will do calculations for the center of the disk instead
//            // of the upper limb.
//            tmp = -(34.0 / 60.0) * SunMoonCalculator.DEG_TO_RAD - pos[3]
//        case .TWILIGHT_CIVIL:
//            tmp = -6 * SunMoonCalculator.DEG_TO_RAD
//        case .TWILIGHT_NAUTICAL:
//            tmp = -12 * SunMoonCalculator.DEG_TO_RAD
//        case .TWILIGHT_ASTRONOMICAL:
//            tmp = -18 * SunMoonCalculator.DEG_TO_RAD
//        }
//
//        // Compute cosine of hour angle
//        tmp = (sin(tmp) - sin(obsLat) * sin(dec)) / (cos(obsLat) * cos(dec))
//        let celestialHoursToEarthTime: Double = SunMoonCalculator.RAD_TO_DAY / SunMoonCalculator.SIDEREAL_DAY_LENGTH
//
//        // Make calculations for the meridian
//        let transit_time1: Double = celestialHoursToEarthTime * SunMoonCalculator.normalizeRadians(ra - lst)
//        let transit_time2: Double = celestialHoursToEarthTime * (SunMoonCalculator.normalizeRadians(ra - lst) - SunMoonCalculator.TWO_PI)
//        var transit_alt: Double = asin(sin(dec) * sin(obsLat) + cos(dec) * cos(obsLat))
//        if (transit_alt > -3 * SunMoonCalculator.DEG_TO_RAD) {
//            let r: Double = 0.016667 * SunMoonCalculator.DEG_TO_RAD * abs(tan(SunMoonCalculator.PI_OVER_TWO - (transit_alt * SunMoonCalculator.RAD_TO_DEG +  7.31 / (transit_alt * SunMoonCalculator.RAD_TO_DEG + 4.4)) * SunMoonCalculator.DEG_TO_RAD))
//            let refr: Double = r * ( 0.28 * 1010 / (10 + 273.0)) // Assuming pressure of 1010 mb and T = 10 C
//            transit_alt = min(transit_alt + refr, SunMoonCalculator.PI_OVER_TWO) // This is not accurate, but acceptable
//        }
//
//        // Obtain the current event in time
//        var transit_time: Double = transit_time1
//        let jdToday: Double = floor(jd_UT - 0.5) + 0.5
//        let transitToday2: Double = floor(jd_UT + transit_time2 - 0.5) + 0.5
//        // Obtain the transit time. Preference should be given to the closest event
//        // in time to the current calculation time
//        if (jdToday == transitToday2 && abs(transit_time2) < abs(transit_time1)) {
//            transit_time = transit_time2
//        }
//        let transit: Double = jd_UT + transit_time
//
//        // Make calculations for rise and set
//        var rise: Double = -1, set: Double = -1
//        if (abs(tmp) <= 1.0) {
//            let ang_hor: Double = abs(acos(tmp))
//            let rise_time1: Double = celestialHoursToEarthTime * SunMoonCalculator.normalizeRadians(ra - ang_hor - lst)
//            let set_time1: Double = celestialHoursToEarthTime * SunMoonCalculator.normalizeRadians(ra + ang_hor - lst)
//            let rise_time2: Double = celestialHoursToEarthTime * (SunMoonCalculator.normalizeRadians(ra - ang_hor - lst) - SunMoonCalculator.TWO_PI)
//            let set_time2: Double = celestialHoursToEarthTime * (SunMoonCalculator.normalizeRadians(ra + ang_hor - lst) - SunMoonCalculator.TWO_PI)
//
//            // Obtain the current events in time. Preference should be given to the closest event
//            // in time to the current calculation time (so that iteration in other method will converge)
//            var rise_time: Double = rise_time1
//            let riseToday2: Double = floor(jd_UT + rise_time2 - 0.5) + 0.5
//            if (jdToday == riseToday2 && abs(rise_time2) < abs(rise_time1)) {
//                rise_time = rise_time2
//            }
//
//            var set_time: Double = set_time1
//            let setToday2: Double = floor(jd_UT + set_time2 - 0.5) + 0.5
//            if (jdToday == setToday2 && abs(set_time2) < abs(set_time1)) {
//                set_time = set_time2
//            }
//            rise = jd_UT + rise_time
//            set = jd_UT + set_time
//        }
//
//        return [azi, alt, rise, set, transit, transit_alt, ra, dec, dist]
//    }
//
//    /**
//     * Transforms a Julian day (rise/set/transit fields) to a common date.
//     * @param jd The Julian day.
//     * @return A set of integers: year, month, day, hour, minute, second.
//     * @throws Exception If the input date does not exists.
//     */
//    class func getDate(_ jd: Double) throws -> [Int] {
//        if (jd < 2299160.0 && jd >= 2299150.0) {
//            throw SunMoonCalculator.Errors.invalidJulianDay(jd: jd)
//        }
//
//        // The conversion formulas are from Meeus,
//        // Chapter 7.
//        let Z: Double = floor(jd + 0.5)
//        let F: Double = jd + 0.5 - Z
//        var A: Double = Z
//        if (Z >= 2299161) {
//            let a: Int = Int((Z - 1867216.25) / 36524.25)
//            A += 1 + Double(a) - Double(a) / 4
//        }
//        let B: Double = A + 1524
//        let C: Int = Int((B - 122.1) / 365.25)
//        let D: Int = Int(Double(C) * 365.25)
//        let E: Int = Int((B - Double(D)) / 30.6001)
//
//        let exactDay: Double = F + B - Double(D) - Double(Int(30.6001 * Double(E)))
//        let day: Int = Int(exactDay)
//        let month: Int = (E < 14) ? E - 1:E - 13
//        var year: Int = C - 4715
//        if (month > 2) {
//            year -= 1
//        }
//        let h: Double = ((exactDay - Double(day)) * SunMoonCalculator.SECONDS_PER_DAY) / 3600.0
//
//        let hour: Int = Int(h)
//        let m: Double = (h - Double(hour)) * 60.0
//        let minute: Int = Int(m)
//        let second: Int = Int((m - Double(minute)) * 60)
//
//        return [year, month, day, hour, minute, second]
//    }
//
//    /**
//     * Returns a date as a string.
//     * @param jd The Juliand day.
//     * @return The String.
//     * @throws Exception If the date does not exists.
//     */
//    class func getDateAsString(_ jd: Double) throws -> String {
//        if (jd == -1) {
//            return "NO RISE/SET/TRANSIT FOR THIS OBSERVER/DATE"
//        }
//
//        var date: [Int] = try SunMoonCalculator.getDate(jd)
//        return "\(date[0])/\(date[1])/\(date[2]) \(date[3]):\(date[4]):\(date[5]) UT"
//    }
//
//    /**
//     * Reduce an angle in radians to the range (0 - 2 Pi).
//     *
//     * @param r Value in radians.
//     * @return The reduced radian value.
//     */
//    class func normalizeRadians(_ r: Double) -> Double {
//        var r: Double = r
//        if (r < 0 && r >= -SunMoonCalculator.TWO_PI) {
//            return r + SunMoonCalculator.TWO_PI
//        }
//        if (r >= SunMoonCalculator.TWO_PI && r < SunMoonCalculator.FOUR_PI) {
//            return r - SunMoonCalculator.TWO_PI
//        }
//        if (r >= 0 && r < SunMoonCalculator.TWO_PI) {
//            return r
//        }
//
//        r -= SunMoonCalculator.TWO_PI * floor(r * SunMoonCalculator.TWO_PI_INVERSE)
//        if (r < 0) {
//            r += SunMoonCalculator.TWO_PI
//        }
//
//        return r
//    }
//
//    private func obtainAccurateRiseSetTransit(riseSetJD: Double, index: Int, niter: Int, sun: Bool) -> Double {
//        var riseSetJD: Double = riseSetJD
//        var step: Double = -1
//        for _ in 0..<niter {
//            if (riseSetJD == -1) {
//                return riseSetJD // -1 means no rise/set from that location
//            }
//            setUTDate(riseSetJD)
//            var out: [Double]
//            if (sun) {
//                out = doCalc(getSun())
//            } else {
//                _ = getSun()
//                out = doCalc(getMoon())
//            }
//            step = abs(riseSetJD - out[index])
//            riseSetJD = out[index]
//        }
//        if (step > 1.0 / SunMoonCalculator.SECONDS_PER_DAY) {
//            return -1 // did not converge => without rise/set/transit in this date
//        }
//        return riseSetJD
//    }
//}
