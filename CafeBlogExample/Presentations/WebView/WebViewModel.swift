//
//  WebViewModel.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import Foundation

import RxCocoa
import RxSwift

class WebViewModel: WebViewBindable {
    var postData: Driver<SearchResultCellData>
    
    init(post: SearchResultCellData) {
        
        postData = Observable.just(post)
            .asDriver(onErrorDriveWith: .empty())
        
    }
}
