//
//  SearchViewModel.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation

import RxCocoa
import RxSwift

class SearchViewModel: SearchViewBindable {
    
    var didTapSearch = PublishSubject<String>()
    var didSelectSort = PublishSubject<SortType>()
    var didSelectFilter = PublishSubject<FilterType>()
    var didScroll = PublishSubject<Void>()
    var willDisplayCell = PublishSubject<Int>()
    var searchList: Driver<[SearchResultCellData]>
    var viewEndEditing: Signal<Void>
    var errorMessage: Signal<String>
    
    private var disposeBag = DisposeBag()
    private var searchedBlogPosts = BehaviorSubject<[Post]>(value: [])
    private var searchedCafePosts = BehaviorSubject<[Post]>(value: [])
    private var cellData = BehaviorSubject<[SearchResultCellData]>(value: [])
    
    init(model: SearchModel = SearchModel()) {
        
        var cafePage = 1
        var blogPage = 1
        
        //CAFE DATA
        let searchCafeResult = didTapSearch
            .do(onNext: { [weak searchedCafePosts] _ in
                cafePage = 1
                searchedCafePosts?.onNext([])
            })
            .flatMapLatest{ model.getCafePosts(query: $0) }
            .share()
        
        let needMoreFetch = Observable
            .combineLatest(
                willDisplayCell,
                cellData
            )
            .map(model.needMoreFetch)
            
        
        let moreCafeResult = needMoreFetch
            .filter { $0 == true }
            .withLatestFrom(didTapSearch)
            .map { (keyword: $0, page: cafePage) }
            .flatMapLatest(model.getCafePosts)
            .share()
        
        let cafeSuccess = Observable
            .merge(
                searchCafeResult,
                moreCafeResult
            )
            .map { result -> [Post]? in
                guard case .success(let value) = result else { return nil }
                if !value.meta.isEnd {
                    cafePage += 1
                }
                return value.documents
            }.compactMap { $0 }
       
        cafeSuccess
            .bind(to: searchedCafePosts)
            .disposed(by: disposeBag)
            
        
        //1. 마지막셀일때
        //2. 페이징
        //3. 키워드 + 페이지 해서 moreFetch 하고
        //4. 리턴
        
        //BLOG DATA
        let searchBlogResult = didTapSearch
            .do(onNext: { [weak searchedBlogPosts] _ in
                blogPage = 1
                searchedBlogPosts?.onNext([])
            })
            .flatMapLatest{ model.getBlogPosts(query: $0) }
            .share()
            
        let moreBlogResult = needMoreFetch
            .filter { $0 == true }
            .withLatestFrom(didTapSearch)
            .map { (keyword: $0, page: cafePage) }
            .flatMapLatest(model.getBlogPosts)
            .share()
        
        let blogSuccess = Observable
            .merge(
                searchBlogResult,
                moreBlogResult
            )
            .map { result -> [Post]? in
                guard case .success(let value) = result else { return nil }
                if !value.meta.isEnd {
                    blogPage += 1
                }
                return value.documents
            }.compactMap { $0 }
       
        blogSuccess
            .bind(to: searchedBlogPosts)
            .disposed(by: disposeBag)
    
        let result = Observable
            .merge(
                searchedBlogPosts,
                searchedCafePosts
            )
            .scan([], accumulator: model.merge)
            .map(model.parsData)
        
        result
            .withLatestFrom(didSelectFilter) { (list: $0, filter: $1) }
            .map(model.filteredData)
            .withLatestFrom(didSelectSort) { (list: $0, sort: $1) }
            .map(model.sortedData)
            .bind(to: cellData)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(didSelectFilter, didSelectSort)
            .map { $0.0 }
            .withLatestFrom(result) { (list: $1, filter: $0) }
            .map(model.filteredData)
            .withLatestFrom(didSelectSort) { (list: $0, sort: $1) }
            .map(model.sortedData)
            .bind(to: cellData)
            .disposed(by: disposeBag)
        
        searchList = cellData
            .asDriver(onErrorDriveWith: .empty())
        
        viewEndEditing = Observable
            .merge(
                didScroll,
                didTapSearch.map { _ in Void() },
                didSelectFilter.map { _ in Void() },
                didSelectSort.map { _ in Void() }
            )
            .asSignal(onErrorSignalWith: .empty())
        
        let empty = Observable
            .combineLatest(
                cafeSuccess,
                blogSuccess
            )
            .map { cafe, blog -> String? in
                if (cafe + blog).count == 0 {
                    return "검색 결과가 없습니다."
                } else {
                    return nil
                }
            }.compactMap { $0 }
        
        let cafeFailure = Observable
            .merge(
                searchCafeResult,
                moreCafeResult
            )
        
        let blogFailure = Observable
            .merge(
                searchCafeResult,
                moreCafeResult
            )
        
        let errors = Observable
            .merge(
                cafeFailure,
                blogFailure
            )
            .map { result -> String? in
                guard case .failure(let error) = result else { return nil }
                return error.message
            }.compactMap { $0 }
        
        errorMessage = Observable.merge(errors, empty)
            .asSignal(onErrorSignalWith: .empty())
        
    }
    
    
}
