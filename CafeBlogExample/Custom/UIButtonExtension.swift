//
//  UIButtonExtension.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation
import UIKit

extension UIButton {
    func setAttributedTitle(title: String, font weight: FontWeight,
                            size: CGFloat,
                            color: UIColor? = nil,
                            for state: UIControl.State = .normal) {
        let attri = NSMutableAttributedString(string: title,
                                              attributes: [.font : UIFont(name: weight.rawValue,
                                                                          size: size)!,
                                                           .foregroundColor : color ?? .black])
        self.setAttributedTitle(attri, for: state)
    }
    
}
