//
//  UILabelExtension.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation
import UIKit

extension UILabel {
    
    convenience init(font weight: FontWeight, size: CGFloat, color: UIColor? = nil) {
        self.init()
        self.font = UIFont(name: weight.rawValue, size: size)
        if let color = color {
            self.textColor = color
        }
    }
    
}
