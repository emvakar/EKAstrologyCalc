//
//  String+Extension.swift
//  AstrologyCalc
//
//  Created by Егор on 28/06/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

extension String {
    
    var toDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        formatter.timeZone = TimeZone.current
        let date = formatter.date(from: self)
        return date
    }
}
