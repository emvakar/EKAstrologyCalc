[![Swift Version](https://img.shields.io/badge/Swift-5.4-green.svg)](https://swift.org) ![Platform](https://img.shields.io/badge/platforms-iOS%2011.0%20%7C%20tvOS%2011.0%20%7C%20watchOS%205.0%20%7C%20macOS%2010.12-green) [![Build Status](https://travis-ci.com/emvakar/EKAstrologyCalc.svg?branch=master)](https://travis-ci.com/emvakar/EKAstrologyCalc) [![Xcode](https://img.shields.io/badge/Xcode-12.0-blue.svg)](https://developer.apple.com/xcode)

# Astrology Calculator
This is Sun/Moon Calculator Framework written on Swift
Get moon and sun info by Date and Location
### Support EKAstrologyCalc development by giving a ⭐️
 

# What we can do right now:

### Moon
- [x] moon rise for given date
- [x] moon set for given date
- [x] moon age for given date
- [x] moon zodiac sign
- [x] moon phase
- [x] moon trajectory
- [x] moon illumination
- [x] moon days at given date
- [x] moon day start time
- [x] moon day ending time
- [x] get eclipse times (begin, duration, finish)

- [ ] moon zodiac sign rise time
- [ ] moon zodiac sign set time
- [ ] moon mercury status and times
- [ ] mercury status and times
- [ ] create UI for calendar

### Sun
- [x] sun rise for given date
- [x] sun set for given date
- [x] sun distance
- [x] sun azimuth


## Requirements

- iOS 11.0+ / tvOS 11.0+ / watchOS 4.0+
- Xcode 12.5+
- Swift 5+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but MRGpsDataGetter does support its use on supported platforms.

Once you have your Swift package set up, adding MRGpsDataGetter as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
    .package(url: "https://github.com/emvakar/EKAstrologyCalc.git", from: "1.1.0")
```

## Usage

### Example


```swift
import UIKit
import CoreLocation
import EKAstrologyCalc

class ViewController: UIViewController {

    let location = CLLocation(latitude: 55.751244, longitude: 37.618423) // center of Moscow

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let astroCalc = EKAstrologyCalc(location: location)

        let info = astroCalc.getInfo(date: Date())

        print("Current localtion: -", info.location.coordinate)

        print("Moon days at", "current date: -", info.date)
        info.moonModels.forEach {
            print("===========")
            print("Moon Age: -", $0.age)
            print("Moon rise: -", $0.moonRise)
            print("Moon set: -", $0.moonSet)
        }
        print("===========")
        print("Moon phase: -", info.phase)
        print("Moon trajectory: -", info.trajectory)
    }
}
```

more info u can find in tests

# Models

### EKAstrologyModel

```swift
public class EKAstrologyModel {

    public var date: Date = Date()

    public var location: CLLocation

    public var trajectory: EKMoonTrajectory

    public var phase: EKMoonPhase

    public var moonModels: [EKMoonModel]
    
    public let nextLunarEclipse: EKEclipse
    
    public let previousLunarEclipse: EKEclipse
    
    public let illumination: EKIllumination?

    public let sunInfo: EKInfoModel?
    public let moonInfo: EKInfoModel?
    
}
```


### EKMoonTrajectory

```swift
public enum EKMoonTrajectory {
    case ascendent
    case descendent
}
```


### EKMoonPhase

```swift
public enum EKMoonPhase: String {
    case newMoon
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case fullMoon
    case waningGibbous
    case lastQuarter
    case waningCrescent
}
```


### EKMoonModel

```swift
public class EKMoonModel {

    public var age: Int

    public var sign: EKMoonZodiacSign

    public var begin: Date?

    public var finish: Date?
    
}
```


### EKEclipse

```swift
public class EKEclipse {
    
    public enum EclipseType {
        case undefined
        case SolarNoncenral
        case SolarPartial
        case SolarCentralTotal
        case SolarCentralAnnular
        case SolarCentralAnnularTotal
        case LunarUmbralTotal
        case LunarUmbralPartial
        case LunarPenumbral
    }
    
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
    public var maxPhaseDate:Date?
    
    /** Maximal phase of eclipse */
    public var phase:Double = 0
    
    /** Type of eclipse */
    public var type: EclipseType = .undefined
    
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
```


### EKIllumination

```swift
public struct EKIllumination {
    
    public let fraction: Double
    public let phase: Double
    public let angle: Double
    
}
```

EKAstrologuCalc is released under the MIT license. See [LICENSE](https://github.com/emvakar/EKAtrologyCalc/blob/master/LICENSE) for more information.
