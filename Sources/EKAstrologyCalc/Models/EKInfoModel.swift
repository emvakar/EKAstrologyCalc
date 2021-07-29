//
//  EKInfoModel.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 29.07.2021.
//

import Foundation
/*
 var sunAz: Double
 var sunEl: Double
 var sunRise: Double
 var sunSet: Double
 var sunTransit: Double
 var sunTransitElev: Double
 var sunDist: Double

 /** Values for azimuth
  var elevation, rise, set, and transit for the Moon. Angles in radians, rise ... as Julian days in UT.
  * Moon age is the number of days since last new Moon, in days, from 0 to 29.5. Distance in AU. */
 var moonAz: Double
 var moonEl: Double
 var moonRise: Double
 var moonSet: Double
 var moonTransit: Double
 var moonAge: Double
 var moonTransitElev: Double
 var moonDist: Double
 */

public class EKInfoModel {

    public var sunRiseSet: EKRiseSetModel?
    public var moonRiseSet: EKRiseSetModel?

    public var sunAz: Double?
    public var sunEl: Double?
    public var sunTransit: Double?
    public var sunTransitElev: Double?
    public var sunDist: Double?

    public var moonAz: Double?
    public var moonEl: Double?
    public var moonTransit: Double?
    public var moonAge: Double?
    public var moonTransitElev: Double?
    public var moonDist: Double?

    init(sunRiseSet: EKRiseSetModel? = nil,
         moonRiseSet: EKRiseSetModel? = nil,
         
         sunAz: Double? = nil,
         sunEl: Double? = nil,
         sunTransit: Double? = nil,
         sunTransitElev: Double? = nil,
         sunDist: Double? = nil,

         moonAz: Double? = nil,
         moonEl: Double? = nil,
         moonTransit: Double? = nil,
         moonAge: Double? = nil,
         moonTransitElev: Double? = nil,
         moonDist: Double? = nil) {

        func rad2deg(_ number: Double) -> Double {
            return number * 180 / .pi
        }


        // sun
        self.sunRiseSet = sunRiseSet
        self.sunTransit = sunTransit

        if let value = sunAz {
            self.sunAz = rad2deg(value)
        }
        if let value = sunEl {
            self.sunEl = rad2deg(value)
        }
        if let value = sunTransitElev {
            self.sunTransitElev = rad2deg(value)
        }
        if let value = sunDist {
            self.sunDist = value * 149597870.700
        }



        // moon

        self.moonRiseSet = moonRiseSet
        self.moonTransit = moonTransit
        self.moonAge = moonAge

        if let value = moonAz {
            self.moonAz = rad2deg(value)
        }
        if let value = moonEl {
            self.moonEl = rad2deg(value)
        }
        if let value = moonTransitElev {
            self.moonTransitElev = rad2deg(value)
        }
        if let value = moonDist {
            self.moonDist = value * 149597870.700
        }

    }

}
