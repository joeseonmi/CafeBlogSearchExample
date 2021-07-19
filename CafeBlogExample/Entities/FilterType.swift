//
//  PostType.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation


enum FilterType: CaseIterable {
    case all
    case blog
    case cafe
    
    var title: String {
        switch self {
        case .all:
            return "전체"
        case .blog:
            return "블로그"
        case .cafe:
            return "카페"
        }
    }
}
