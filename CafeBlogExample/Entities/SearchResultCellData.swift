//
//  SearchResultCellData.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import Foundation

struct SearchResultCellData: Hashable {
    let title: String
    let contents: String
    let url: String
    let blogName: String?
    let cafeName: String?
    let thumbnailURL: String
    let datetime: Date?
    var type: FilterType {
        return blogName == nil ? .cafe : .blog
    }
}
