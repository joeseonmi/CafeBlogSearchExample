//
//  UIViewExtension.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation
import SnapKit
import UIKit

extension UIView {
    var safeArea: ConstraintBasicAttributesDSL {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        } else {
            return self.snp
        }
    }
}
