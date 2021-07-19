//
//  DateExtension.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation
import UIKit

extension Date {
    
    func toString(format: String = "yyyy-MM-dd") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: self)
    }
}
