//
//  Eclipse.swift
//  AstrologyCalc
//
//  Created by  Yuri on 02/04/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation


/// Provides detailed info about eclipse (lunar or solar).
public class Eclipse {
    
    // Types of eclipse
    public static let SOLAR = 0
    public static let LUNAR = 1
    
    // Details of eclipses
    public static let SOLAR_NONCENTRAL            = 0;
    public static let SOLAR_PARTIAL               = 1;
    public static let SOLAR_CENTRAL_TOTAL         = 2;
    public static let SOLAR_CENTRAL_ANNULAR       = 3;
    public static let SOLAR_CENTRAL_ANNULAR_TOTAL = 4;
    public static let LUNAR_UMBRAL_TOTAL          = 5;
    public static let LUNAR_UMBRAL_PARTIAL        = 6;
    public static let LUNAR_PENUMBRAL             = 7;
    
    // Local visibility circumstances (lunar & solar both)
    public static let VISIBILITY_NONE             = 0;
    public static let VISIBILITY_PARTIAL          = 1;
    public static let VISIBILITY_FULL             = 2;
    public static let VISIBILITY_START_PENUMBRA   = 3;
    public static let VISIBILITY_START_PARTIAL    = 4;
    public static let VISIBILITY_START_FULL       = 5;
    public static let VISIBILITY_END_FULL         = 6;
    public static let VISIBILITY_END_PARTIAL      = 7;
    public static let VISIBILITY_END_PENUMBRA     = 8;
    
    /** UTC date & time of maximal phase of eclipse (for Earth center) */
    public var jd:Double = 0
    
    /** Maximal phase of eclipse */
    public var phase:Double = 0
    
    /** Type of eclipse */
    public var type:Int?
    
    /** Minimal distance between:
     a) solar eclipse: center of Moon shadow axis and Earth center;
     b) lunar eclipse: Moon center and Earth shadow axis. */
    public var gamma:Double = 0
    
    /** Radius of ...  */
    public var u:Double = 0
    
    /** Eclipse visibiliy for local point */
    public var visibility:Int?
    
    /** Julian date for observable phase */
    public var jdBestVisible:Double?
    
    // LUNAR ECLIPSE
    
    /** Penumra radius (in Earth equatorial radii) */
    public var rho:Double?
    
    /** Umbra radius (in Earth equatorial radii) */
    public var sigma:Double?
    
    /** Semiduration of partial phase in penumbra, in minutes */
    public var sdPenumbra:Double?
    
    /** Semiduration of partial phase, in minutes */
    public var sdPartial:Double?
    
    /** Semiduration of total phase, in minutes */
    public var sdTotal:Double?
    
    // SOLAR ECLIPSE
    
    /** Maximal local phase of eclipse */
    public var phaseLocal:Double?
    
    /** UTC date & time eclipse maximum for local point */
    public var jdLocal:Double?
    
    /** Time of partial phase beginning for local point */
    public var jdLocalPartialStart:Double?
    
    /** Time of partial phase ending for local point */
    public var jdLocalPartialEnd:Double?
}
