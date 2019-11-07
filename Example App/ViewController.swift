//
//  ViewController.swift
//  Example App
//
//  Created by Emil Karimov on 27/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit
import CoreLocation
import AstrologyCalc
import DevHelper

class ViewController: UIViewController {

    let location = CLLocation(latitude: 55.751244, longitude: 37.618423)
    var moonPhaseManager: MoonCalculatorManager!

    weak var container: UIStackView!

    override func loadView() {
        super.loadView()

        let container = self.stackView(orientation: .vertical, distribution: .fillProportionally, spacing: 10)

        self.view.addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: container, attribute: .topMargin, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1.0, constant: 64),
            NSLayoutConstraint(item: container, attribute: .leftMargin, relatedBy: .equal, toItem: self.view, attribute: .leftMargin, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: container, attribute: .rightMargin, relatedBy: .equal, toItem: self.view, attribute: .rightMargin, multiplier: 1.0, constant: -16),
            ])
        self.container = container

    }

    override func viewDidLoad() {
        super.viewDidLoad()


        self.newSystem()
    }

    fileprivate func getInfoFor(_ date: Date) {
        do {
            let smc = try SunMoonCalculator(date: date, longitude: 37.618423, latitude: 55.751244)
            smc.calcSunAndMoon()
            
            print("\n=== === \(date.toString()) === ===")
//            print("Azimuth:\t\t\(Float(smc.moonAzimuth.toDegrees))\u{00b0}")
//            print("Elevation:\t\t\(Float(smc.moonElevation.toDegrees))\u{00b0}")
//            print("Distance:\t\t\(Float(smc.moonDistance * SunMoonCalculator.AU)) km")
            print("Age:\t\t\t\(Float(smc.moonAge)) days")
//            print("Illumination:\t\(Float(smc.moonIllumination * 100))%")
            print("Phase:\t\t\t\(smc.moonPhase)")
            print("Rise:\t\t\t\(getDateAsString(date: try SunMoonCalculator.getDate(jd: smc.moonRise)))")
            print("Set:\t\t\t\(getDateAsString(date: try SunMoonCalculator.getDate(jd: smc.moonSet)))")
            print("Transit:\t\t\(getDateAsString(date: try SunMoonCalculator.getDate(jd: smc.moonTransit))) (max. elevation \(Float(smc.moonTransitElevation.toDegrees))\u{00b0})")
            
        } catch {
            print(error)
        }
    }
    
    private func newSystem() {
        print("Started...")

//        guard let date = Date(fromString: "1.10.2019", format: .custom("dd.MM.yyyy"), timeZone: .utc) else { return }
//
//        for i in 0...30 {
//            let newDate = date.adjust(.day, offset: i)
//            self.getInfoFor(newDate)
//        }
                guard let date = Date(fromString: "28.10.2019", format: .custom("dd.MM.yyyy"), timeZone: .local) else { return }
        
                for i in 0...3600 {
                    let newDate = date.adjust(.minute, offset: i)
                    self.getInfoFor(newDate)
                }

    }

    /** Method to display a textual representation of Date*/
    func getDateAsString(date: Date, utc: Bool? = false) -> String {
        var calendar: Calendar = Calendar.init(identifier: .gregorian)
        if utc! {
            calendar.timeZone = TimeZone.init(abbreviation: "UTC")!
        }
        let dc: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return String(format: "%d/%02d/%02d %02d:%02d:%02d", dc.year!, dc.month!, dc.day!, dc.hour!, dc.minute!, dc.second!)
    }

    private func oldFunction() {
        print("Started...")

        self.view.backgroundColor = .white
        self.moonPhaseManager = MoonCalculatorManager(location: location)

        /////-------- проверка лунных дней -----------
        let countries = DataBaseManager().makeCountriesFromJSON()
        let firstCity = countries[0].cities[0]

        let manager = MoonCalculatorManager(location: CLLocation(latitude: 55.751244, longitude: 37.618423))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        var dateComponents = DateComponents(calendar: calendar, year: 2019, month: 5, day: 23, hour: 00, minute: 00)
        dateComponents.calendar = calendar
        dateComponents.timeZone = calendar.timeZone

        //        guard let day = calendar.date(from: dateComponents) else {return}
        guard let day = Date(fromString: "28.10.2019", format: .custom("dd.MM.yyyy")) else { return }

        //        let moons = firstCity.moonDays.filter({
        //
        //            if ($0.date?.isSameDate(day)) ?? false || ($0.date?.isSameDate(day.adjust(.day, offset: -1)) ?? false) || ($0.date?.isSameDate(day.adjust(.day, offset: 1)) ?? false) {
        //                return true
        //            }
        //            return false
        //        })
        //
        //        let newCity = DBCityModel(cityName: firstCity.cityName, moonDays: moons)
        //
        let models = manager.getMoonModels(date: day, city: firstCity, timeZone: TimeZone.current)
        /////////////////////////////////////////////////////////////

        let info = self.moonPhaseManager.getInfo(date: day, city: firstCity, timeZone: TimeZone.current)

        self.addInfo(param: "=== Current localtion ===", value: "", on: self.container, textAlignment: .center)
        self.addInfo(param: "Latitude", value: "\(info.location.coordinate.latitude)", on: self.container, textAlignment: .left)
        self.addInfo(param: "Longitude", value: "\(info.location.coordinate.longitude)", on: self.container, textAlignment: .left)
        self.addInfo(param: "=== Current date ===", value: "", on: self.container, textAlignment: .center)
        self.addInfo(param: "", value: "\(info.date.toString())", on: self.container, textAlignment: .left)

        info.moonModels.forEach {
            self.addInfo(param: "=== Moon day", value: "\($0.age) ===", on: self.container, textAlignment: .center)
            self.addInfo(param: "Moon rise", value: $0.moonRise == nil ? "Yesterday" : "\($0.moonRise!.toString())", on: self.container, textAlignment: .left)
            self.addInfo(param: "Moon set", value: $0.moonSet == nil ? "Tomorrow" : "\($0.moonSet!.toString())", on: self.container, textAlignment: .left)
        }

        self.addInfo(param: "Moon phase", value: "\(info.phase)", on: self.container, textAlignment: .left)
        self.addInfo(param: "Moon trajectory", value: "\(info.trajectory)", on: self.container, textAlignment: .left)
        self.addInfo(param: "Previous eclipse", value: "\(info.previousLunarEclipse.maxPhaseDate!.toString()))", on: self.container, textAlignment: .left)
        self.addInfo(param: "Next eclipse", value: "\(info.nextLunarEclipse.maxPhaseDate!.toString()))", on: self.container, textAlignment: .left)


        let dateString = "22.05.2019"
        guard let date = Date(fromString: dateString, format: .custom("dd.MM.yyyy")) else {
            fatalError("cant get date from string!")
        }

        let days = self.moonPhaseManager.getMoonDays(at: date)
        print(days)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

}


// MARK: - Privates
extension ViewController {

    private func addInfo(param: String, value: String, on stackView: UIStackView, textAlignment: NSTextAlignment) {

        let container = UILabel()
        container.textAlignment = textAlignment
        container.text = param + " " + value

        container.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)

        stackView.addArrangedSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([container.heightAnchor.constraint(equalToConstant: 35)])
        print(param, value, "\n")
    }

    private func stackView(orientation: NSLayoutConstraint.Axis = .vertical, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = orientation
        stackView.distribution = distribution
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = spacing
        return stackView
    }

}


