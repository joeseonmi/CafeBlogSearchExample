//
//  CellData.swift
//  CafeBlogExampleTests
//
//  Created by 조선미 on 2021/07/20.
//

import Foundation

@testable import CafeBlogExample
struct CellDummy {
    
    let cellResultDummy35 = (BlogResultDummy().blogResultDummy.documents + CafeResultDummy().cafeResultDummy.documents).map { SearchResultCellData(title: $0.title, contents: $0.contents, url: $0.url, blogName: $0.blogName, cafeName: $0.cafeName, thumbnailURL: $0.thumbnailURL, datetime: $0.datetime) }
    
    let cellResultSortTest = BlogResultDummy().blogResultDummy.documents.map { SearchResultCellData(title: $0.title, contents: $0.contents, url: $0.url, blogName: $0.blogName, cafeName: $0.cafeName, thumbnailURL: $0.thumbnailURL, datetime: $0.datetime) }
                          
}
