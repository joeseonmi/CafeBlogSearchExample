//
//  SearchModel.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation

import RxCocoa
import RxSwift


struct SearchModel {
    
    var network: SearchAPIService!
    
    init(network: SearchAPIService = .shared ) {
        self.network = network
    }
    
    func getCafePosts(query: String, page: Int = 1) -> Observable<Result<PostResponse, SearchError>> {
        return network.getCafePosts(query: query, page: page)
    }
    
    func getBlogPosts(query: String, page: Int = 1) -> Observable<Result<PostResponse, SearchError>> {
        return network.getBlogPosts(query: query, page: page)
    }
    
    func parsData(input: [Post]) -> [SearchResultCellData] {
        return input.map { SearchResultCellData(title: $0.title.withoutTag,
                                                contents: $0.contents.withoutTag,
                                                url: $0.url,
                                                blogName: $0.blogName,
                                                cafeName: $0.cafeName,
                                                thumbnailURL: $0.thumbnailURL,
                                                datetime: $0.datetime) }
    }
    
    func needMoreFetch(row: Int, cells: [SearchResultCellData]) -> Bool {
        if cells.count >= 25 {
            return cells.count == row + 1
        } else {
            return false
        }
    }
    
    func merge(pre: [Post], next: [Post]) -> [Post] {
        return next.count == 0 ? next : pre + next
    }
    
    func filteredData(input: [SearchResultCellData], filter: FilterType) -> [SearchResultCellData] {
        switch filter {
        case .all:
            return input
        case .blog:
            return input.filter { $0.type == .blog }
        case .cafe:
            return input.filter { $0.type == .cafe }
        }
    }
    
    func sortedData(input: [SearchResultCellData], sort: SortType) -> [SearchResultCellData] {
        switch sort {
        case .title:
            return input.sorted(by: { return $0.title < $1.title })
        case .dateTime:
            return input.sorted(by: { return $0.datetime ?? Date() > $1.datetime ?? Date() })
        }
    }
}
