//
//  StringExtension.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation
import UIKit

extension String {
    
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    var withoutTag: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&[^;]+;", with: "", options:.regularExpression, range: nil)
    }
}
