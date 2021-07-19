//
//  SortType.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/17.
//

import Foundation


enum SortType: CaseIterable {
    case title
    case dateTime
    
    var title: String {
        switch self {
        case .title:
            return "제목 순"
        case .dateTime:
            return "최신날짜 순"
        }
    }
}
