//
//  EKAstrologyCalc.swift
//  EKAstrologyCalc
//
//  Created by Emil Karimov on 03/06/202020.
//  Copyright © 2020 Emil Karimov. All rights reserved.
//

import CoreLocation
import ESDateHelper

/// Calculator
public class EKAstrologyCalc {

    var location: CLLocation!

    private let moonAgeCalculator: EKMoonAgeCalculatorProtocol  = EKMoonAgeCalculator()
    
    private let moonZodiaSignCalculator: EKMoonZodiacSignCalculatorProtocol = EKMoonZodiacSignCalculator()
    
    private lazy var moonRiseSetCalculator: EKMoonRiseSetCalculatorProtocol = EKMoonRiseSetCalculator(location: location)
    
    private lazy var moonPhaseCalculator: EKMoonPhaseCalculatorProtocol = EKMoonPhaseCalculator(moonAgeCalculator: moonAgeCalculator)
    
    private lazy var moontrajectoryCalculator: EKMoonTrajectoryCalculatorProtocol = EKMoonTrajectoryCalculator(moonAgeCalculator: moonAgeCalculator)

    // MARK: - Init
    
    public init() { }

    /// get information by date
    /// - Parameter date: current date
    /// - Returns: Astrology model
    public func getInfo(date: Date, location: CLLocation) -> EKAstrologyModel {
        self.location = location
        
        let phase = moonPhaseCalculator.getMoonPhase(date: date)

        let trajectory = moontrajectoryCalculator.getMoonTrajectory(date: date)
        let moonModels = getMoonModels(date: date)
        
        let eclipses = [
            EKEclipseCalculator.getEclipseFor(date: date, eclipseType: .lunar, next: false),
            EKEclipseCalculator.getEclipseFor(date: date, eclipseType: .lunar, next: true)
        ]

        let sunMoonCalc = try? EKSunMoonCalculator(date: date, location: location)
        sunMoonCalc?.calcSunAndMoon()

        let illumination = sunMoonCalc?.getMoonIllumination(date: date)

        let sunModel = EKSunCalculator(date: date, location: location)?.getSolar()
        let moonModel = getMoonRiseSet(date: date)

        let sunInfo = EKInfoModel(sunRiseSet: sunModel,
                                  moonRiseSet: moonModel,
                                  sunAz: sunMoonCalc?.sunAz,
                                  sunEl: sunMoonCalc?.sunEl,
                                  sunTransit: sunMoonCalc?.sunTransit,
                                  sunTransitElev: sunMoonCalc?.sunTransitElev,
                                  sunDist: sunMoonCalc?.sunDist)

        let moonInfo = EKInfoModel(moonRiseSet: moonModel,
                                   moonAz: sunMoonCalc?.moonAz,
                                   moonEl: sunMoonCalc?.moonEl,
                                   moonTransit: sunMoonCalc?.moonTransit,
                                   moonAge: sunMoonCalc?.moonAge,
                                   moonTransitElev: sunMoonCalc?.moonTransitElev,
                                   moonDist: sunMoonCalc?.moonDist)

        let astrologyModel = EKAstrologyModel(
            date: date,
            location: location,
            trajectory: trajectory,
            phase: phase,
            moonModels: moonModels,
            lunarEclipses: eclipses,
            illumination: illumination,
            sunInfo: sunInfo,
            moonInfo: moonInfo
        )

        return astrologyModel
    }
    
}

// MARK: - Private

extension EKAstrologyCalc {

    private func getMoonRiseSet(date: Date) -> EKRiseSetModel? {
        let moonRise = try? moonRiseSetCalculator.getMoonRiseDay(date: date).get()
        let moonSet = try? moonRiseSetCalculator.getMoonSetDay(date: date).get()
        let moonModel = EKRiseSetModel(rise: moonRise, set: moonSet)
        return moonModel
    }

    // Получить модели лунного дня для текущего человеческого дня
    private func getMoonModels(date: Date) -> [EKMoonModel] {
        let startDate = date.startOfDay
        guard let endDate = date.endOfDay else { return [] }

        let ages = moonAgeCalculator.getMoonAges(date: date)
        let moonRise = try? moonRiseSetCalculator.getMoonRise(date: startDate).get()
        let moonSet = try? moonRiseSetCalculator.getMoonSet(date: endDate).get()
        let zodiacSignStart = moonZodiaSignCalculator.getMoonZodicaSign(date: startDate)
        let zodiacSignEnd = moonZodiaSignCalculator.getMoonZodicaSign(date: endDate)

        let prevStartDay = startDate.adjust(.day, offset: -1).startOfDay
        let nextEndDate = endDate.adjust(.day, offset: 1).endOfDay!

        let prevMoonRise = try? moonRiseSetCalculator.getMoonRise(date: prevStartDay).get()
        var nextMoonRise = try? moonRiseSetCalculator.getMoonRise(date: nextEndDate).get()

        if ages.count < 1 {
            return []
        } else if ages.count == 1 {
            let model = EKMoonModel(age: ages[0], sign: zodiacSignEnd, begin: prevMoonRise, finish: nextMoonRise)
            return [model]
        } else if ages.count == 2 {

            if (moonSet?.timeIntervalSince1970 ?? 0) < (nextMoonRise?.timeIntervalSince1970 ?? 0) && (moonSet?.timeIntervalSince1970 ?? 0) > (moonRise?.timeIntervalSince1970 ?? 0) {
                nextMoonRise = try? moonRiseSetCalculator.getMoonRise(date: endDate).get()
            }

            let model1 = EKMoonModel(age: ages[0], sign: zodiacSignStart, begin: prevMoonRise, finish: moonRise)
            let model2 = EKMoonModel(age: ages[1], sign: zodiacSignEnd, begin: moonRise, finish: nextMoonRise)
            return [model1, model2]
        } else if ages.count == 3 {
            if (moonSet?.timeIntervalSince1970 ?? 0) < (nextMoonRise?.timeIntervalSince1970 ?? 0) && (moonSet?.timeIntervalSince1970 ?? 0) > (moonRise?.timeIntervalSince1970 ?? 0) {
                nextMoonRise = try? moonRiseSetCalculator.getMoonRise(date: endDate).get()
            }

            let middleZodiacSign = (zodiacSignStart == zodiacSignEnd) ? zodiacSignStart : zodiacSignEnd
            let model1 = EKMoonModel(age: ages[0], sign: zodiacSignStart, begin: prevMoonRise, finish: moonRise)
            let model2 = EKMoonModel(age: ages[1], sign: middleZodiacSign, begin: moonRise, finish: moonSet)
            let model3 = EKMoonModel(age: ages[2], sign: zodiacSignEnd, begin: moonSet, finish: nextMoonRise)
            return [model1, model2, model3]
        } else {
            return []
        }
    }
}
