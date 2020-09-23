//
//  Double+Extension.swift
//  EKAstrologyCalc
//
//  Created by Vasile Morari on 23.09.2020.
//

import Foundation

internal extension Double {
    //нормализовать число, т.е. число от 0 до 1
    var normalized: Double {
        var v = self - floor(self)
        if (v < 0) {
            v = v + 1
        }
        return v
    }
}
