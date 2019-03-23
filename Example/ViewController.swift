//
//  ViewController.swift
//  Example
//
//  Created by Emil Karimov on 23/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let location = CLLocation(latitude: 55.751244, longitude: 37.618423)
    var moonPhaseManager: MoonCalculatorManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.moonPhaseManager = MoonCalculatorManager(location: location)

        let info = self.moonPhaseManager.getInfo(date: Date())

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
