//
//  PostDetailViewModel.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import Foundation

import RxCocoa
import RxSwift

class PostDetailViewModel: PostDetailViewBindable {
    
    var pushWebViewURL: Driver<SearchResultCellData>
    var didTapMoveToWebView = PublishSubject<Void>()
    var viewWillDisappear = PublishSubject<Void>()
    
    var postData: Driver<SearchResultCellData>
    
    init(post: SearchResultCellData) {
        
        postData = Observable.just(post)
            .asDriver(onErrorDriveWith: .empty())
        
        pushWebViewURL = didTapMoveToWebView
            .do(onNext: { MoveToURLManager.shared.setMoveToURL(id: post.hashValue) })
            .map { post }
            .asDriver(onErrorDriveWith: .empty())
        
    }
}
