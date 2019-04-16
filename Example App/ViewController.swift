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
        
        self.view.backgroundColor = .white
        self.moonPhaseManager = MoonCalculatorManager(location: location)
        
        let info = self.moonPhaseManager.getInfo(date: Date())
        
        self.addInfo(param: "=== Current localtion ===", value: "", on: self.container, textAlignment: .center)
        self.addInfo(param: "Latitude", value: "\(info.location.coordinate.latitude)", on: self.container, textAlignment: .left)
        self.addInfo(param: "Longitude", value: "\(info.location.coordinate.longitude)", on: self.container, textAlignment: .left)
        self.addInfo(param: "=== Current date ===", value: "", on: self.container, textAlignment: .center)
        self.addInfo(param: "", value: "\(info.date)", on: self.container, textAlignment: .left)
        
        info.moonModels.forEach {
            self.addInfo(param: "=== Moon day", value: "\($0.age) ===", on: self.container, textAlignment: .center)
            self.addInfo(param: "Moon rise", value: $0.moonRise == nil ? "Yesterday" : "\($0.moonRise!)", on: self.container, textAlignment: .left)
            self.addInfo(param: "Moon set", value: $0.moonSet == nil ? "Tomorrow" : "\($0.moonSet!)", on: self.container, textAlignment: .left)
        }
        
        self.addInfo(param: "Moon phase", value: "\(info.phase)", on: self.container, textAlignment: .left)
        self.addInfo(param: "Moon trajectory", value: "\(info.trajectory)", on: self.container, textAlignment: .left)
        self.addInfo(param: "Previous eclipse", value: "\(info.previousLunarEclipse.maxPhaseDate!))", on: self.container, textAlignment: .left)
        self.addInfo(param: "Next eclipse", value: "\(info.nextLunarEclipse.maxPhaseDate!))", on: self.container, textAlignment: .left)
        
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


